defmodule Shux.Bot.Handlers.MessageHandler do
  alias Shux.Bot.Commands

  @commands %{
    avatar: Commands.Avatar,
    banner: Commands.Banner,
    ticket: Commands.Ticket,
    profile: Commands.Profile,
    rank: Commands.Rank,
    leaderboard: Commands.Leaderboard,
    lb: Commands.Leaderboard,
    help: Commands.Help,
    inventory: Commands.Inventory,
    inv: Commands.Inventory
  }

  def handle(data) do
    content = data.content

    if is_command?(content) do
      [command | args] = parse_content(content)
      current_command = Map.get(@commands, command)

      unless current_command == nil do
        # perms will be deleted after we setup the api
        # so that we can get user permissions from there
        perms = current_command.help().perms

        {_status, _res} = current_command.run(perms, data, args)
      end
    end
  end

  def handle(_data, :deleted) do
  end

  def handle(_data, :edited) do
  end

  def get_commands, do: @commands

  def is_command?(content),
    do: String.downcase(content) |> String.starts_with?(["shux!", "shx!", "sh!", "sx!"])

  def parse_content(content) do
    content
    |> String.split("!")
    |> tl()
    |> List.to_string()
    |> String.split()
    |> (fn [command | args] ->
          [command |> String.downcase() |> String.to_atom() | args]
        end).()
  end
end
