defmodule Shux.Bot.Commands.Profile do
  alias Shux.Api
  alias Shux.Discord
  alias Shux.Bot.Leveling.LevelXpConverter
  @behaviour Shux.Bot.Command

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
    } = Api.get_user(user.id)

    username = user.username <> " #" <> user.discriminator
    level = Integer.to_string(LevelXpConverter.xp_to_level(String.to_integer(points)))
    avatar = Discord.Api.user_avatar(user)

    image =
      Shux.ImageBuilder.Profile.build(
        avatar,
        {
          username,
          points,
          level,
          warns,
          desc
        }
      )

    Discord.Api.send_image(msg.channel_id, image)

    {:ok, nil}
  end
end
