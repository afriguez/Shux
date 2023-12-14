defmodule Shux do
  use Application

  import Cachex.Spec

  def start(_type, _args) do
    children = [
      %{
        id: Shux.Discord.Gateway.Client,
        start: {Shux.Discord.Gateway.Client, :start_link, []}
      },
      %{
        id: Shux.ApiSessionScheduler,
        start: {Shux.ApiSessionScheduler, :start_link, []}
      },
      {Cachex,
       name: :shux_cache,
       stats: true,
       limit:
         limit(
           size: 350,
           policy: Cachex.Policy.LRW,
           reclaim: 0.5
         )}
    ]

    opts = [strategy: :one_for_one, name: Shux.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
