defmodule Shux.Api do
  use HTTPoison.Base

  @endpoint "https://shux.adrephos.com/api/v1"

  def process_url(url), do: @endpoint <> url

  def initial_headers do
    [
      {"Authorization", "Bearer " <> Application.get_env(:shux, :api_token)},
      {"Content-Type", "application/json"}
    ]
  end
end
