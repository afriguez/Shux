defmodule Shux.Bot.Commands.Banner do
  @behaviour Shux.Bot.Command

  alias Shux.Discord.Api

  def help() do
    %{
      usage: "sx!banner @user",
      description: "Muestra el banner del usuario.",
      perms: :user,
      options: ""
    }
  end

  def run(_perms, msg, _args) do
    user = if Enum.empty?(msg.mentions), do: msg.author, else: hd(msg.mentions)
    user = Api.user(user.id)

    if !user.banner do
      Api.send_message(msg.channel_id, "Oops! no tiene banner...")
    else
      is_gif = String.starts_with?(user.banner, "a_")

      banner_ext = if is_gif, do: ".gif", else: ".png"

      content =
        "https://cdn.discordapp.com/banners/#{user.id}/#{user.banner <> banner_ext}?size=1024"

      Api.send_message(msg.channel_id, content)
    end

    {:ok, nil}
  end
end
