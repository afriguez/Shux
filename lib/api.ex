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

  import Bitwise

  alias Shux.Discord.Cache
  alias Shux.Api.User

  @endpoint "https://shux.adrephos.com/api/v1"
  @roles %{
    admin: 1 <<< 1,
    mod: 1 <<< 2,
    tech: 1 <<< 3,
    colour: 1 <<< 5
  }

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

  def handle_response(%HTTPoison.Response{body: body}) do
    case Poison.decode!(body, %{keys: :atoms}) do
      %{success: true, data: data} -> {:ok, data}
      %{success: false, error: reason} -> {:error, reason}
    end
  end

  def get_user(guild_id, user_id) do
    route = "/servers/#{guild_id}/users/#{user_id}"

    case get!(route, headers()) |> handle_response() do
      {:ok, user} -> {:ok, struct(User, user)}
      _ -> update_user(guild_id, user_id, %User{})
    end
  end

  def update_user(guild_id, user_id, user) do
    encoded_user = user |> Poison.encode!()
    route = "/servers/#{guild_id}/users/#{user_id}"

    case patch!(route, encoded_user, headers()) |> handle_response() do
      {:ok, user} -> {:ok, struct(User, user)}
      error -> error
    end
  end

  def set_description(guild_id, user_id, description) do
    update_user(guild_id, user_id, %{description: description})
  end

  def get_rank(guild_id, user_id) do
    route = "/servers/#{guild_id}/users/#{user_id}/rank"

    case get!(route, headers()) |> handle_response() do
      {:ok, data} -> {:ok, data.user}
      error -> error
    end
  end

  def get_leaderboard(guild_id) do
    route = "/servers/#{guild_id}/leaderboard"

    case get!(route, headers()) |> handle_response() do
      {:ok, data} -> {:ok, data.ranking}
      error -> error
    end
  end

  def get_roles(guild_id) do
    route = "/servers/#{guild_id}/roles"

    case get!(route, headers()) |> handle_response() do
      {:ok, data} -> {:ok, data}
      error -> error
    end
  end

  def post_role(guild_id, role_id, name, flags) do
    role = Poison.encode!(%{name: name, flags: flags})
    route = "/servers/#{guild_id}/roles/#{role_id}"

    case post!(route, role, headers()) |> handle_response() do
      {:ok, data} -> {:ok, data}
      error -> error
    end
  end

  def get_colors(guild_id) do
    case get_roles(guild_id) do
      {:ok, data} -> {:ok, filter_colors(data.roles)}
      error -> error
    end
  end

  defp filter_colors(roles) do
    Enum.reduce(
      roles,
      [],
      &if(&1.flags == @roles.colour, do: [&1 | &2], else: &2)
    )
    |> Enum.sort_by(& &1.level, :asc)
  end
end
