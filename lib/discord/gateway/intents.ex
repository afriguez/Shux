defmodule Shux.Discord.Gateway.Intents do
  import Bitwise

  def value(client_intents) when is_list(client_intents) do
    Enum.reduce(intents(), 0, fn {k, v}, acc ->
      if Enum.find(client_intents, &(&1 == k)), do: acc + v, else: acc
    end)
  end

  def intents do
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
end
