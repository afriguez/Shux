defmodule Shux.Bot.Commands.Role do
  @behaviour Shux.Bot.Command

  alias Shux.Discord.Cache
  alias Shux.Bot.Components
  alias Shux.Discord.Api

  def help() do
    %{
      usage: "sx!role @role",
      description: "Crea un boton para dar el rol especificado.",
      perms: :admin,
      options: ""
    }
  end

  def run(:admin, msg, ["<@" <> _role_id | t]) do
    [role_id | _t] = msg.mention_roles
    guild = Cache.get_guild(msg.guild_id)
    role = guild.roles |> Enum.find(fn r -> r.id == role_id end)

    Api.send_message(msg.channel_id, %{
      content: Enum.join(t, " "),
      components: [
        Components.action_row([
          Components.button(
            style: 1,
            label: role.name,
            custom_id: "role-#{role_id}"
          )
        ])
      ]
    })

    {:ok, nil}
  end

  def run(:admin, _msg, _args), do: {:invalid, "Bad format"}

  def run(_perms, _msg, _args), do: {:invalid, "Not authorized"}
end
