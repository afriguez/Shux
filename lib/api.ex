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

  def login() do
    password = Application.get_env(:shux, :password) |> parse_env()
    username = Application.get_env(:shux, :username) |> parse_env()
    post_body = %{username: username, password: password} |> Poison.encode!()

    %HTTPoison.Response{body: res_body} = post!("/auth/login", post_body, initial_headers())
    %{"accessToken" => access, "refreshToken" => refresh} = (res_body |> Poison.decode!())["data"]

    {access, refresh}
  end

  def refresh(token) do
    post_body = %{token: token} |> Poison.encode!()
    %HTTPoison.Response{body: res_body} = post!("/auth/refresh", post_body, initial_headers())
    %{"accessToken" => access, "refreshToken" => refresh} = (res_body |> Poison.decode!())["data"]

    {access, refresh}
  end

  def parse_env(var) do
    case Regex.run(~r/'(.*)'/, var) do
      [_, content] -> content
      _ -> var
    end
  end
end
