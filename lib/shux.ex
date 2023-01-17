defmodule Shux do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Shux.Discord.Gateway.Client,
        start: {Shux.Discord.Gateway.Client, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: Shux.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
