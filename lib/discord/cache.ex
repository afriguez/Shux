defmodule Shux.Discord.Cache do
  @cache :shux_cache

  defp put(key, data) do
    Cachex.put(@cache, key, data, ttl: :timer.minutes(30))
  end

  def put_user(user) do
    put({:user, user.id}, user)
  end

  def put_guild(guild_id, guild) do
    put({:guild, guild_id}, guild)
  end

  def put_commands(commands) do
    put(:cmds, commands)
  end

  def put_leaderboard(guild_id, url) do
    put({:lb, guild_id}, url)
  end

  def put_member(guild_id, member) do
    Cachex.get_and_update(@cache, {:member, guild_id}, fn
      nil -> {:commit, %{member.user.id => member}}
      members -> {:commit, Map.put(members, member.user.id, member)}
    end)
  end

  def get_user(user_id) do
    Cachex.get!(@cache, {:user, user_id})
  end

  def get_guild(guild_id) do
    Cachex.get!(@cache, {:guild, guild_id})
  end

  def get_member(guild_id, user_id) do
    case Cachex.get!(@cache, {:member, guild_id}) do
      nil -> nil
      members -> Map.get(members, user_id)
    end
  end

  def get_commands() do
    Cachex.get!(@cache, :cmds)
  end

  def get_leaderboard(guild_id) do
    Cachex.get!(@cache, {:lb, guild_id})
  end
end
