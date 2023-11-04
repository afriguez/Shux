defmodule Shux.Bot.Interactions.Rank do
  import Bitwise

  alias Shux.Bot.Components
  alias Shux.Bot.Leveling.LevelXpConverter
  alias Shux.ImageBuilder
  alias Shux.Api
  alias Shux.Discord

  def run(%{data: %{custom_id: "rank_position"}, member: member} = interaction) do
    user = member.user
    rank = Api.get_rank!(user.id)

    response = %{
      type: 4,
      data: %{
        content: "Estas en el rango **##{rank}**",
        flags: 1 <<< 6
      }
    }

    Discord.Api.interaction_callback(interaction, response)
  end

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

    %{points: points} = Api.get_user!(target_id)
    rank = Api.get_rank!(target_id)

    username = user.username
    level = LevelXpConverter.xp_to_level(points)
    avatar = Discord.Api.user_avatar(user)

    image =
      ImageBuilder.Rank.build(avatar, {
        username,
        points,
        level,
        rank
      })

    response = %{
      type: 4,
      data: %{
        content: "",
        components: [
          Components.action_row([
            Components.profile_avatar_btn(user.id),
            Components.banner_btn(user.id)
          ])
        ]
      }
    }

    Discord.Api.interaction_callback(interaction, response, image)
  end
end
