defmodule Shux.Discord.BitValues do
  import Bitwise

  def value_of(:permissions, keys) do
    value(keys, permissions())
  end

  def value_of(:intents, keys) do
    value(keys, intents())
  end

  defp value(keys, map) do
    Enum.reduce(map, 0, fn {k, v}, acc ->
      if Enum.find(keys, &(&1 == k)), do: acc + v, else: acc
    end)
  end

  defp permissions do
    %{
      guilds: 1 <<< 0,
      guild_members: 1 <<< 1,
      guild_bans: 1 <<< 2,
      guild_emojis_and_stickers: 1 <<< 3,
      guild_integrations: 1 <<< 4,
      guild_webhooks: 1 <<< 5,
      guild_invites: 1 <<< 6,
      guild_voice_states: 1 <<< 7,
      guild_presences: 1 <<< 8,
      guild_messages: 1 <<< 9,
      guild_message_reactions: 1 <<< 10,
      guild_message_typing: 1 <<< 11,
      direct_messages: 1 <<< 12,
      direct_message_reactions: 1 <<< 13,
      direct_message_typing: 1 <<< 14,
      message_content: 1 <<< 15,
      guild_scheduled_events: 1 <<< 16,
      auto_moderation_configuration: 1 <<< 20,
      auto_moderation_execution: 1 <<< 21
    }
  end

  defp intents do
    %{
      view_channel: 1 <<< 10,
      send_messages: 1 <<< 11,
      embed_links: 1 <<< 14,
      attach_files: 1 <<< 15,
      read_message_history: 1 <<< 16
    }
  end
end
