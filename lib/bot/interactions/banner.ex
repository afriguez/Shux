defmodule Shux.Bot.Interactions.Banner do
  import Bitwise

  alias Shux.Discord.Api

  def run(interaction) do
    user = interaction.member.user
    user = Api.user(user.id)

    if !user.banner do
      Api.interaction_callback(interaction, %{
        type: 4,
        data: %{content: "Oops! no tienes banner", flags: 1 <<< 6}
      })
    else
      is_gif = String.starts_with?(user.banner, "a_")
      banner_ext = if is_gif, do: ".gif", else: ".png"

      banner_url =
        "https://cdn.discordapp.com/banners/#{user.id}/#{user.banner <> banner_ext}?size=1024"

      response = %{
        type: 4,
        data: %{
          content: banner_url,
          flags: 1 <<< 6
        }
      }

      Api.interaction_callback(interaction, response)
    end
  end
end
