defmodule Shux.Discord.Cache do
  @cache :shux_cache

  defp put(key, data) do
    Cachex.put(@cache, key, data, ttl: :timer.minutes(30))
  end
end
