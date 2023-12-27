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

    case Api.get_rank(msg.guild_id, user.id) do
      {:ok, %{rank: rank, points: points}} ->
        username = user.username
        level = LevelXpConverter.xp_to_level(points)
        avatar = Discord.Api.user_avatar(user)

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

      {:error, _reason} ->
        Discord.Api.send_message(msg.channel_id, "**#{String.capitalize(user.username)}** no tiene puntaje!")
    end

    {:ok, nil}
  end
end
