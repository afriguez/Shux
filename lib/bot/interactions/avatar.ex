defmodule Shux.Bot.Interactions.Avatar do
  import Bitwise

  alias Shux.Discord.Cache
  alias Shux.Bot.Components
  alias Shux.Discord.Api

  def run(interaction) do
    response = run_avatar(interaction)
    Api.interaction_callback(interaction, response)
  end

  defp run_avatar(%{data: %{custom_id: "profile_avatar-" <> user_id}}) do
    user = Api.user(user_id)
    avatar_url = user_avatar(user_id, user.avatar)

    %{
      type: 4,
      data: %{
        content: avatar_url,
        flags: 1 <<< 6,
        components: components("avatar-#{user_id}", avatar_url)
      }
    }
  end

  defp run_avatar(%{data: %{custom_id: "member_avatar-" <> user_id}}) do
    user = Api.user(user_id)

    avatar_url = user_avatar(user_id, user.avatar)

    %{
      type: 7,
      data: %{
        content: avatar_url,
        components: components("avatar-#{user_id}", avatar_url)
      }
    }
  end

  defp run_avatar(%{data: %{custom_id: "avatar-" <> user_id = custom_id}} = interaction) do
    guild_id = interaction.guild_id
    member = Api.member(guild_id, user_id)

    member_has_avatar = member.avatar != nil

    {avatar_url, custom_id} =
      if String.starts_with?(custom_id, "avatar") and member_has_avatar do
        {
          member_avatar(guild_id, user_id, member.avatar),
          "member_avatar-#{user_id}"
        }
      else
        {
          user_avatar(user_id, member.user.avatar),
          "avatar-#{user_id}"
        }
      end

    %{
      type: 7,
      data: %{
        content: avatar_url,
        components: components(custom_id, avatar_url)
      }
    }
  end

  defp run_avatar(interaction) do
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
        member_avatar(interaction.guild_id, user.id, member.avatar)
      else
        user_avatar(user.id, user.avatar)
      end

    Cache.put_user(user)

    member =
      if Map.get(member, :user) == nil do
        Map.put(member, :user, user)
      else
        member
      end

    Cache.put_member(interaction.guild_id, member)

    %{
      type: 4,
      data: %{
        content: avatar_url,
        components: components("member_avatar-#{user.id}", avatar_url)
      }
    }
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
        Components.url_btn(avatar_url)
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
