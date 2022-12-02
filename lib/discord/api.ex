defmodule Shux.Discord.Api do
  use HTTPoison.Base

  @endpoint "https://discord.com/api/v10"

  def process_url(url) do
    @endpoint <> url
  end
end
