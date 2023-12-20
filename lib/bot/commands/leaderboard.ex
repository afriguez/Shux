defmodule Shux.Bot.Commands.Leaderboard do
  @behaviour Shux.Bot.Command

  alias Shux.Discord.Cache
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
    case Cache.get_leaderboard(msg.guild_id) do
      nil ->
        case build_leaderboard(msg.guild_id) do
          {:error, reason} ->
            IO.inspect(reason)
            Discord.Api.send_message(msg.channel_id, "No hay suficientes personas en el ranking.")

          leaderboard_img ->
            send_attachment(msg, leaderboard_img)
        end

      leaderboard_img ->
        send_attachment(msg, leaderboard_img)
    end

    {:ok, nil}
  end

  defp build_leaderboard(guild_id) do
    case Api.get_leaderboard(guild_id) do
      {:ok, users} ->
        Enum.reduce(users, [], fn user, acc ->
          discord_user = Discord.Api.user(user.id)
          avatar = Discord.Api.user_avatar(discord_user)
          level = LevelXpConverter.xp_to_level(user.points)

          [{avatar, discord_user.username, user.points, level} | acc]
        end)
        |> Enum.reverse()
        |> Leaderboard.build()

      error ->
        error
    end
  end

  defp send_attachment(msg, leaderboard_img) do
    Discord.Api.send_message(
      msg.channel_id,
      %{
        content: "",
        components: components()
      },
      leaderboard_img
    )

    Cache.put_leaderboard(msg.guild_id, leaderboard_img)
  end

  defp components() do
    [
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
  end
end
