defmodule Shux.Discord.Api do
  use HTTPoison.Base

  alias Shux.Discord.Cache

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

  def user(user_id) do
    case Cache.get_user(user_id) do
      nil -> fetch_user(user_id)
      user -> user
    end
  end

  def fetch_user(user_id) do
    %HTTPoison.Response{body: body} = get!("/users/#{user_id}", headers())

    user = Poison.decode!(body, %{keys: :atoms})
    Cache.put_user(user)

    user
  end

  def member(guild_id, user_id) do
    case Cache.get_member(guild_id, user_id) do
      nil ->
        fetch_member(guild_id, user_id)

      member ->
        member
    end
  end

  def fetch_member(guild_id, user_id) do
    %HTTPoison.Response{body: body} =
      get!("/guilds/#{guild_id}/members/#{user_id}", headers())

    member = Poison.decode!(body, %{keys: :atoms})
    Cache.put_member(guild_id, member)

    member
  end

  def global_commands() do
    case Cache.get_commands() do
      nil -> fetch_global_commands()
      cmds -> cmds
    end
  end

  def fetch_global_commands() do
    app_id = Application.get_env(:shux, :app_id)

    %HTTPoison.Response{body: body} =
      get!("/applications/#{app_id}/commands", headers())

    cmds = Poison.decode!(body, %{keys: :atoms})
    Cache.put_commands(cmds)

    cmds
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

  def send_message(ch_id, message, image) do
    body =
      {:multipart,
       [
         {"json", Poison.encode!(message), {"form-data", [name: "payload_json"]}, []},
         {"file", image, {"form-data", [name: "file", filename: "file.png"]}, []}
       ]}

    post(
      "/channels/#{ch_id}/messages",
      body,
      [
        {"Authorization", "Bot " <> Application.get_env(:shux, :bot_token)},
        {"Content-Type", "multipart/form-data"}
      ]
    )
  end

  def send_image(ch_id, image) do
    body =
      {:multipart,
       [
         {"file", image, {"form-data", [name: "file", filename: "file.png"]}, []}
       ]}

    post(
      "/channels/#{ch_id}/messages",
      body,
      [
        {"Authorization", "Bot " <> Application.get_env(:shux, :bot_token)},
        {"Content-Type", "multipart/form-data"}
      ]
    )
  end

  def user_avatar(user) do
    %HTTPoison.Response{body: body} =
      HTTPoison.get!("https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}.png")

    body
  end

  def create_channel(guild_id, channel) when is_map(channel) do
    post(
      "/guilds/#{guild_id}/channels",
      Poison.encode!(channel),
      headers()
    )
  end

  def delete_channel(channel_id) when is_binary(channel_id),
    do: delete("/channels/#{channel_id}", headers())

  def interaction_callback(interaction, response, image) do
    body =
      {:multipart,
       [
         {"json", Poison.encode!(response), {"form-data", [name: "payload_json"]}, []},
         {"file", image, {"form-data", [name: "file", filename: "file.png"]}, []}
       ]}

    post(
      "/interactions/#{interaction.id}/#{interaction.token}/callback",
      body,
      [
        {"Authorization", "Bot " <> Application.get_env(:shux, :bot_token)},
        {"Content-Type", "multipart/form-data"}
      ]
    )
  end

  def interaction_callback(interaction, response) when is_map(response) do
    post(
      "/interactions/#{interaction.id}/#{interaction.token}/callback",
      Poison.encode!(response),
      headers()
    )
  end

  def register_command(name, description, options) do
    app_id = Application.get_env(:shux, :app_id)

    command = %{
      name: name,
      description: description,
      options: options,
      dm_permission: false,
      type: 1
    }

    post(
      "/applications/#{app_id}/commands",
      Poison.encode!(command),
      headers()
    )
  end

  def delete_command(cmd_id) do
    app_id = Application.get_env(:shux, :app_id)
    delete("/applications/#{app_id}/commands/#{cmd_id}", headers())
  end
end
