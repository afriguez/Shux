defmodule Shux.Discord.Api do
  use HTTPoison.Base

  @endpoint "https://discord.com/api/v10"

  def headers do
    [
      {"Authorization", "Bot " <> Application.get_env(:shux, :bot_token)},
      {"Content-Type", "application/json"}
    ]
  end

  def process_url(url) do
    @endpoint <> url
  end

  def send_message(ch_id, content) when is_binary(content) do
    post(
      "/channels/#{ch_id}/messages",
      Poison.encode!(%{content: content}),
      headers()
    )
  end

  def send_message(ch_id, message) when is_map(message) do
    post(
      "/channels/#{ch_id}/messages",
      Poison.encode!(message),
      headers()
    )
  end

  def create_channel(guild_id, channel) when is_map(channel) do
    post(
      "/guilds/#{guild_id}/channels",
      Poison.encode!(channel),
      headers()
    )
  end

  def interaction_callback(interaction, response) when is_map(response) do
    post(
      "/interactions/#{interaction.id}/#{interaction.token}/callback",
      Poison.encode!(response),
      headers()
    )
  end
end
