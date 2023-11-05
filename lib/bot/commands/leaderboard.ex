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
        leaderboard_img = build_leaderboard(msg.guild_id)
        send_attachment(msg, leaderboard_img)

      url ->
        send_url(msg.channel_id, url)
    end

    {:ok, nil}
  end

  defp build_leaderboard(guild_id) do
    users = Api.get_leaderboard!(guild_id)

    Enum.reduce(users, [], fn user, acc ->
      discord_user = Discord.Api.user(user.id)
      avatar = Discord.Api.user_avatar(discord_user)
      level = LevelXpConverter.xp_to_level(user.points)

      [{avatar, discord_user.username, user.points, level} | acc]
    end)
    |> Enum.reverse()
    |> Leaderboard.build()
  end

  defp send_attachment(msg, leaderboard_img) do
    {:ok, response} =
      Discord.Api.send_message(
        msg.channel_id,
        %{
          content: "",
          components: components()
        },
        leaderboard_img
      )

    %HTTPoison.Response{body: body} = response
    body = Poison.decode!(body, %{keys: :atoms})
    leaderboard = hd(body.attachments)

    Cache.put_leaderboard(msg.guild_id, leaderboard.url)
  end

  defp send_url(channel_id, url) do
    Discord.Api.send_message(channel_id, %{
      content: url,
      components: components()
    })
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
