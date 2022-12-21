defmodule Shux.Bot.Interactions.Avatar do
  alias Shux.Bot.Components
  alias Shux.Discord.Api

  def run(interaction) do
    custom_id = interaction.data.custom_id
    user_id = interaction.member.user.id

    guild_id = interaction.guild_id
    member_has_avatar = interaction.member.avatar != nil

    {content, custom_id} =
      if custom_id == "avatar" and member_has_avatar do
        {member_avatar(guild_id, user_id, interaction.member.avatar), "member_avatar"}
      else
        {user_avatar(user_id, interaction.member.user.avatar), "avatar"}
      end

    components = [
      Components.action_row([
        Components.button(
          style: 1,
          emoji: %{
            name: "ReimuSociety",
            id: "959791808915832842",
            animated: false
          },
          custom_id: custom_id
        )
      ])
    ]

    response = %{
      type: 7,
      data: %{
        content: content,
        components: components
      }
    }

    Api.interaction_callback(interaction, response)
  end

  def member_avatar(guild_id, user_id, avatar) do
    "https://cdn.discordapp.com/guilds/" <>
      "#{guild_id}/users/#{user_id}/avatars/" <>
      "#{avatar <> avatar_ext(avatar)}?size=1024"
  end

  def user_avatar(user_id, avatar) do
    "https://cdn.discordapp.com/avatars/" <>
      "#{user_id}/#{avatar <> avatar_ext(avatar)}?size=1024"
  end

  def avatar_ext("a_" <> _avatar), do: ".gif"

  def avatar_ext(_avatar), do: ".png"
end
