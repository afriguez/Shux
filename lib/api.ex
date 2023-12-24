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
  @role_flags %{
    admin: 1 <<< 1,
    mod: 1 <<< 2,
    tech: 1 <<< 3,
    user: 1 <<< 4,
    colour: 1 <<< 5
  }
  @channel_flags %{
    tickets: 1 <<< 1
  }

  def process_url(url), do: @endpoint <> url

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

    %HTTPoison.Response{body: res_body} = post!("/auth/login", post_body)
    %{"accessToken" => access, "refreshToken" => refresh} = (res_body |> Poison.decode!())["data"]

    {access, refresh}
  end

  def refresh(token) do
    post_body = %{token: token} |> Poison.encode!()
    %HTTPoison.Response{body: res_body} = post!("/auth/refresh", post_body)
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

  def get_tickets(guild_id) do
    route = "/servers/#{guild_id}/tickets"

    %HTTPoison.Response{body: body} = get!(route, headers())
    {:ok, body} = Poison.decode(body)

    case body do
      %{"success" => true} -> {:ok, body["data"]["tickets"]}
      _ -> {:error, body["error"]}
    end
  end

  def post_ticket(guild_id, user_id, channel_id) do
    route = "/servers/#{guild_id}/tickets"

    {:ok, tickets} = get_tickets(guild_id)
    tickets = Map.put(tickets, user_id, channel_id) |> Poison.encode!()

    %HTTPoison.Response{body: body} = post!(route, tickets, headers())
    {:ok, body} = Poison.decode(body)

    case body do
      %{"success" => true} -> {:ok, body["data"]["tickets"]}
      _ -> {:error, body["error"]}
    end
  end

  def delete_ticket(guild_id, channel_id) do
    route = "/servers/#{guild_id}/tickets"

    {:ok, tickets} = get_tickets(guild_id)

    user_id =
      tickets
      |> Enum.find(fn {_k, v} -> v == channel_id end)
      |> elem(0)

    tickets = Map.drop(tickets, [user_id])
    tickets = Poison.encode!(tickets)

    %HTTPoison.Response{body: body} = post!(route, tickets, headers())
    {:ok, body} = Poison.decode(body)

    case body do
      %{"success" => true} -> {:ok, body["data"]["tickets"]}
      _ -> {:error, body["error"]}
    end
  end

  def get_roles(guild_id) do
    route = "/servers/#{guild_id}/roles"

    case get!(route, headers()) |> handle_response() do
      {:ok, data} -> {:ok, data}
      error -> error
    end
  end

  def post_role(guild_id, role_id, name, flags, level) do
    role = Poison.encode!(%{name: name, flags: flags, level: level})
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

  def get_role_flags, do: @role_flags

  def filter_by_flags(roles, role_flags) do
    Enum.reduce(
      roles,
      [],
      &if(&1.flags == role_flags, do: [&1 | &2], else: &2)
    )
  end

  defp filter_colors(roles) do
    filter_by_flags(roles, @role_flags.colour)
    |> Enum.sort_by(& &1.level, :asc)
  end

  def get_channels(guild_id) do
    route = "/servers/#{guild_id}/channels"

    case get!(route, headers()) |> handle_response() do
      {:ok, data} -> {:ok, data.channels}
      error -> error
    end
  end

  def post_channel(guild_id, channel_id, flags) do
    channel = %{flags: flags} |> Poison.encode!()
    route = "/servers/#{guild_id}/channels/#{channel_id}"

    case post!(route, channel, headers()) |> handle_response() do
      {:ok, data} -> {:ok, data}
      error -> error
    end
  end

  def get_tickets_category(guild_id) do
    case get_channels(guild_id) do
      {:ok, channels} ->
        tickets_category =
          case filter_by_flags(channels, @channel_flags.tickets) do
            [] -> %{id: nil}
            filtered -> hd(filtered)
          end

        {:ok, tickets_category}

      error ->
        error
    end
  end
end
