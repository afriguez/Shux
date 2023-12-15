defmodule Shux.Discord.Cache do
  @cache :shux_cache

  defp put(key, data) do
    Cachex.put(@cache, key, data, ttl: :timer.minutes(30))
  end

  def put_user(user) do
    put({:user, user.id}, user)
  end

  def put_guild(guild_id, guild) do
    Cachex.put(@cache, {:guild, guild_id}, guild)
  end

  def put_commands(commands) do
    put(:cmds, commands)
  end

  def put_leaderboard(guild_id, image) do
    put({:lb, guild_id}, image)
  end

  def put_member(guild_id, member) do
    put({:member, guild_id, member.user.id}, member)
  end

  def get_user(user_id) do
    Cachex.get!(@cache, {:user, user_id})
  end

  def get_guild(guild_id) do
    Cachex.get!(@cache, {:guild, guild_id})
  end

  def get_member(guild_id, user_id) do
    Cachex.get!(@cache, {:member, guild_id, user_id})
  end

  def get_commands() do
    Cachex.get!(@cache, :cmds)
  end

  def get_leaderboard(guild_id) do
    Cachex.get!(@cache, {:lb, guild_id})
  end

  def put_tokens(tokens) do
    Cachex.put(@cache, :tokens, tokens)
  end

  def get_tokens() do
    Cachex.get!(@cache, :tokens)
  end
end
