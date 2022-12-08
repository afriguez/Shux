defmodule Shux.Discord.Api do
  use HTTPoison.Base

  @endpoint "https://discord.com/api/v10"

  @headers [
    {"Authorization", "Bot "},
    {"Content-Type", "application/json"}
  ]

  def process_url(url) do
    @endpoint <> url
  end

  def send_message(ch_id, content) when is_binary(content) do
    post(
      "/channels/#{ch_id}/messages",
      Poison.encode!(%{content: content}),
      @headers
    )
  end

  def send_message(ch_id, message) when is_map(message) do
    post(
      "/channels/#{ch_id}/messages",
      Poison.encode!(message),
      @headers
    )
  end
end
