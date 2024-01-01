defmodule Shux.Bot.Commands.Warn do
  @behaviour Shux.Bot.Command

  alias Shux.Discord.Api

  def help() do
    %{
      usage: "sx!warn @user",
      description: "Warnea a un usuario.",
      perms: :mod,
      options: ""
    }
  end

  def run(:admin, msg, args), do: run(:mod, msg, args)

  def run(:mod, msg, _args) do
    ch_id = msg.channel_id

    if Enum.empty?(msg.mentions) do
      Api.send_message(ch_id, "Debes mencionar a un usuario para warnear.")
    else
      user = hd(msg.mentions)
      guild_id = msg.guild_id

      {:ok, api_user} = Shux.Api.get_user(guild_id, user.id)
      warnings = api_user.warnings + 1

      case rem(warnings, 3) do
        1 -> Api.send_message(ch_id, "#{user.username} ha sido **warneado**.")
        2 -> warn(warnings, guild_id, ch_id, user)
        0 -> ban(guild_id, ch_id, user)
      end

      {:ok, _user} = Shux.Api.update_user(guild_id, user.id, %{warnings: warnings})
    end

    {:ok, nil}
  end

  def run(_perms, _msg, _args), do: {:invalid, "Not authorized"}

  defp warn(warnings, guild_id, ch_id, user) do
    {:ok, _res} = Api.delete("/guilds/#{guild_id}/members/#{user.id}", Api.headers())

    Api.send_message(
      ch_id,
      "#{user.username} ahora tiene: **#{warnings}** warns y ha sido **kickeado**."
    )
  end

  defp ban(guild_id, ch_id, user) do
    {:ok, _res} = Api.put("/guilds/#{guild_id}/bans/#{user.id}", "", Api.headers())
    Api.send_message(ch_id, "#{user.username} ha sido **baneado**.")
  end
end
