defmodule Shux.Bot.Commands.Rank do
  @behaviour Shux.Bot.Command

  alias Shux.Api
  alias Shux.Discord
  alias Shux.ImageBuilder.Rank
  alias Shux.Bot.Leveling.LevelXpConverter

  def help do
    %{
      usage: "sx!rank",
      description: "Muestra el rango del usuario especificado o el autor del mensaje.",
      perms: :user,
      options: ""
    }
  end

  def run(_perms, msg, _args) do
    user = if Enum.empty?(msg.mentions), do: msg.author, else: hd(msg.mentions)

    points = Api.get_user(msg.guild_id, user.id).points

    username = user.username
    level = LevelXpConverter.xp_to_level(points)
    avatar = Discord.Api.user_avatar(user)
    rank = Api.get_rank!(user.id)

    image =
      Rank.build(
        avatar,
        {
          username,
          points,
          level,
          rank
        }
      )

    Discord.Api.send_image(msg.channel_id, image)

    {:ok, nil}
  end
end
