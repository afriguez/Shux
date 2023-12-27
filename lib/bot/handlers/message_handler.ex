defmodule Shux.Bot.Handlers.MessageHandler do
  alias Shux.Bot.Leveling.LevelXpConverter
  alias Shux.Api
  alias Shux.Bot.Leveling.XpCalculator
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
    addcolor: Commands.Addcolor,
    role: Commands.Role
  }

  def handle(data) do
    content = data.content
    xp = XpCalculator.calculate(content)

    guild_id = data.guild_id
    user_id = data.author.id
    member = data.member

    {:ok, api_user} = Api.get_user(guild_id, user_id)
    points = api_user.points + xp
    level = LevelXpConverter.xp_to_level(points)

    {:ok, %{roles: roles}} = Api.get_roles(guild_id)
    role = roles |> Enum.find(fn r -> r.flags == Api.get_role_flags().files end)

    if level >= role.level do
      data.member.roles
      |> Enum.any?(&(&1 == role.id))
      |> unless do
        Shux.Discord.Api.update_member(
          guild_id,
          user_id,
          %{roles: data.member.roles ++ [role.id]}
        )
      end
    end

    Api.update_user(
      guild_id,
      user_id,
      %{points: points}
    )

    if is_command?(content) do
      [command | args] = parse_content(content)
      current_command = Map.get(@commands, command)

      unless current_command == nil do
        perms = get_member_permissions(guild_id, member)
        current_command.run(perms, data, args)
      end
    end
  end

  def handle(_data, :deleted) do
  end

  def handle(_data, :edited) do
  end

  def get_member_permissions(guild_id, %{roles: member_roles}) do
    {:ok, %{roles: api_roles}} = Api.get_roles(guild_id)
    role_flags = Api.get_role_flags()

    ids_api_roles = Enum.reduce(api_roles, [], &[&1.id | &2])
    matches = member_roles -- member_roles -- ids_api_roles

    role =
      Enum.reduce(
        matches,
        %{
          flags: role_flags.user,
          id: "",
          name: "",
          level: 0
        },
        fn role_id, acc ->
          api_role = Enum.find(api_roles, fn e -> e.id == role_id end)

          if api_role.flags < acc.flags,
            do: api_role,
            else: acc
        end
      )

    Enum.find(role_flags, {:user, nil}, fn {_k, v} -> v == role.flags end)
    |> elem(0)
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
