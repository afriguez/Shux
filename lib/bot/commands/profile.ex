defmodule Shux.Bot.Commands.Profile do
  @behaviour Shux.Bot.Command

  alias Shux.Bot.Components
  alias Shux.Api
  alias Shux.Discord
  alias Shux.Bot.Leveling.LevelXpConverter

  def help do
    %{
      usage: "sx!profile @user",
      description: "Muestra el perfil del usuario especificado o el autor del mensaje.",
      perms: :user,
      options: ""
    }
  end

  def run(_perms, msg, _args) do
    user = if Enum.empty?(msg.mentions), do: msg.author, else: hd(msg.mentions)

    %{
      points: points,
      warnings: warns,
      description: desc
    } = Api.get_user!(user.id)

    username = user.username
    level = LevelXpConverter.xp_to_level(points)
    avatar = Discord.Api.user_avatar(user)

    image =
      Shux.ImageBuilder.Profile.build(
        avatar,
        {
          username,
          Integer.to_string(points),
          Integer.to_string(level),
          Integer.to_string(warns),
          desc
        }
      )

    disabled = msg.author.id != user.id

    Discord.Api.send_message(
      msg.channel_id,
      %{
        content: "",
        components: [
          Components.action_row([
            Components.profile_avatar_btn(user.id),
            Components.banner_btn(user.id),
            Components.description_btn(user.id, disabled)
          ])
        ]
      },
      image
    )

    {:ok, nil}
  end
end
