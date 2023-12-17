defmodule Shux.Api do
  use HTTPoison.Base

  alias Shux.Discord.Cache

  @endpoint "https://shux.adrephos.com/api/v1"

  def process_url(url), do: @endpoint <> url

  def initial_headers do
    [
      {"Authorization", "Bearer " <> Application.get_env(:shux, :api_token)},
      {"Content-Type", "application/json"}
    ]
  end

  def headers do
    {access, _refresh} = Cache.get_tokens()

    [
      {"Authorization", "Bearer " <> access},
      {"Content-Type", "application/json"}
    ]
  end

  def parse_env(var) do
    case Regex.run(~r/'(.*)'/, var) do
      [_, content] -> content
      _ -> var
    end
  end
end
