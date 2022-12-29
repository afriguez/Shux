defmodule Shux.Bot.Commands.Avatar do
  alias Shux.Bot.Components
  alias Shux.Discord.Api

  @behaviour Shux.Bot.Command

  def help() do
    %{
      usage: "sx!avatar @user",
      description: "Muestra el avatar del usuario.",
      perms: :user,
      options: ""
    }
  end

  def run(_perms, msg, _args) do
    user = if Enum.empty?(msg.mentions), do: msg.author, else: hd(msg.mentions)
    is_gif = String.starts_with?(user.avatar, "a_")

    avatar_ext = if is_gif, do: ".gif", else: ".png"

    Api.send_message(msg.channel_id, %{
      content:
        "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar <> avatar_ext}?size=1024",
      components: [
        Components.action_row([
          Components.button(
            style: 1,
            label: "Actualizar",
            custom_id: "avatar",
            emoji: %{
              name: "ReimuSociety",
              id: "959791808915832842",
              animated: false
            }
          )
        ])
      ]
    })

    {:ok, nil}
  end
end
