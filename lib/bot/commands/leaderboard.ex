defmodule Shux.Bot.Commands.Leaderboard do
  @behaviour Shux.Bot.Command

  alias Shux.Bot.Components
  alias Shux.Bot.Leveling.LevelXpConverter
  alias Shux.Api
  alias Shux.ImageBuilder.Leaderboard
  alias Shux.Discord

  def help do
    %{
      usage: "sx!leaderboard",
      description: "Muestra la leaderboard del servidor.",
      perms: :user,
      options: ""
    }
  end

  def run(_perms, msg, _args) do
    users = Api.get_leaderboard!(msg.guild_id)

    leaderboard_img =
      Enum.reduce(users, [], fn user, acc ->
        discord_user = Discord.Api.user(user.id)
        avatar = Discord.Api.user_avatar(discord_user)
        level = LevelXpConverter.xp_to_level(user.points)

        [{avatar, discord_user.username, user.points, level} | acc]
      end)
      |> Enum.reverse()
      |> Leaderboard.build()

    Discord.Api.send_message(
      msg.channel_id,
      %{
        content: "",
        components: [
          Components.action_row([
            Components.button(
              style: 1,
              label: "Ver mi posicion",
              custom_id: "rank_position",
              emoji: %{
                name: "frank2",
                id: "735700040655437824"
              }
            )
          ])
        ]
      },
      leaderboard_img
    )

    {:ok, nil}
  end
end
