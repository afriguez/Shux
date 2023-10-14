defmodule Shux.Bot.Interactions.Profile do
  alias Shux.Bot.Leveling.LevelXpConverter
  alias Shux.ImageBuilder
  alias Shux.Api
  alias Shux.Discord
  alias Shux.Bot.Components

  def run(interaction) do
    has_resolved = Map.get(interaction.data, :resolved) != nil

    user =
      if has_resolved do
        key = hd(Map.keys(interaction.data.resolved.users))

        Map.get(interaction.data.resolved.users, key)
      else
        interaction.member.user
      end

    target_id =
      if Map.get(interaction.data, :target_id) != nil do
        interaction.data.target_id
      else
        user.id
      end

    %{points: points, warnings: warns, description: desc} = Api.get_user!(target_id)

    username = user.username
    level = LevelXpConverter.xp_to_level(points)
    avatar = Discord.Api.user_avatar(user)

    image =
      ImageBuilder.Profile.build(
        avatar,
        {
          username,
          "#{points}",
          "#{level}",
          "#{warns}",
          desc
        }
      )

    response = %{
      type: 4,
      data: %{
        content: "",
        components: [
          Components.action_row([
            Components.button(
              style: 1,
              label: "Avatar",
              custom_id: "profile_avatar-#{user.id}",
              emoji: %{
                name: "🖼️"
              }
            ),
            Components.button(
              style: 1,
              label: "Banner",
              custom_id: "banner-#{user.id}",
              emoji: %{
                name: "blondytsundere",
                id: "743640353978056724"
              }
            ),
            Components.button(
              style: 3,
              label: "Actualizar descripcion",
              custom_id: "description-#{user.id}",
              disabled: target_id != interaction.member.user.id,
              emoji: %{
                name: "NoSe",
                id: "748046020935680060"
              }
            )
          ])
        ]
      }
    }

    Discord.Api.interaction_callback(interaction, response, image)
  end
end
