defmodule Shux.Bot.Interactions.Avatar do
  alias Shux.Bot.Components
  alias Shux.Discord.Api

  def run(%{data: %{custom_id: custom_id}} = interaction) do
    user_id = interaction.member.user.id

    guild_id = interaction.guild_id
    member_has_avatar = interaction.member.avatar != nil

    {avatar_url, custom_id} =
      if custom_id == "avatar" and member_has_avatar do
        {
          member_avatar(guild_id, user_id, interaction.member.avatar),
          "member_avatar"
        }
      else
        {
          user_avatar(user_id, interaction.member.user.avatar),
          "avatar"
        }
      end

    response = %{
      type: 7,
      data: %{
        content: avatar_url,
        components: components(custom_id, avatar_url)
      }
    }

    Api.interaction_callback(interaction, response)
  end

  def run(interaction) do
    has_resolved = Map.get(interaction.data, :resolved) != nil

    {user, member} =
      if has_resolved do
        key = hd(Map.keys(interaction.data.resolved.users))

        {
          Map.get(interaction.data.resolved.users, key),
          Map.get(interaction.data.resolved.members, key)
        }
      else
        {interaction.member.user, interaction.member}
      end

    avatar_url =
      if member.avatar != nil do
        member_avatar(interaction.data.guild_id, user.id, member.avatar)
      else
        user_avatar(user.id, user.avatar)
      end

    response = %{
      type: 4,
      data: %{
        content: avatar_url,
        components: components("member_avatar", avatar_url)
      }
    }

    Api.interaction_callback(interaction, response)
  end

  def components(custom_id, avatar_url) do
    [
      Components.action_row([
        Components.button(
          style: 1,
          emoji: %{
            name: "🖼️",
            animated: false
          },
          label: " Actualizar",
          custom_id: custom_id
        ),
        Components.button(
          style: 5,
          label: "Abrir original",
          url: avatar_url
        )
      ])
    ]
  end

  def member_avatar(guild_id, user_id, avatar) do
    "https://cdn.discordapp.com/guilds/" <>
      "#{guild_id}/users/#{user_id}/avatars/" <>
      "#{avatar <> avatar_ext(avatar)}?size=2048"
  end

  def user_avatar(user_id, avatar) do
    "https://cdn.discordapp.com/avatars/" <>
      "#{user_id}/#{avatar <> avatar_ext(avatar)}?size=2048"
  end

  def avatar_ext("a_" <> _avatar), do: ".gif"

  def avatar_ext(_avatar), do: ".png"
end
