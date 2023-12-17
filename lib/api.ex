defmodule Shux.Api.User do
  defstruct [
    :description,
    points: 0,
    show_level: false,
    warnings: 0,
    warnings_record: [],
    beta: false,
    tickets: 0
  ]
end

defmodule Shux.Api do
  use HTTPoison.Base

  alias Shux.Discord.Cache
  alias Shux.Api.User

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

  def get_user(guild_id, user_id) do
    route = "/servers/#{guild_id}/users/#{user_id}"
    %HTTPoison.Response{body: res_body} = get!(route, headers())

    case Poison.decode!(res_body, %{keys: :atoms}) do
      %{success: true, data: user} -> struct(User, user)
      _ -> update_user(guild_id, user_id, %User{})
    end
  end

  def update_user(guild_id, user_id, user) do
    user = user |> Poison.encode!()

    route = "/servers/#{guild_id}/users/#{user_id}"
    %HTTPoison.Response{body: res_body} = post!(route, user, headers())

    %{success: true} = res_body |> Poison.decode!(%{keys: :atoms})
    user
  end

  def set_description(guild_id, user_id, description) do
    update_user(guild_id, user_id, %{description: description})
  end

  def get_rank(guild_id, user_id) do
    route = "/servers/#{guild_id}/users/#{user_id}/rank"
    %HTTPoison.Response{body: res_body} = get!(route, headers())

    %{data: %{user: user}} = res_body |> Poison.decode!(%{keys: :atoms})
    user
  end
end
