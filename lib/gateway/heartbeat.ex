defmodule Shux.Gateway.Heartbeat do
  use GenServer

  def start_link({_interval, _client_pid} = args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init({interval, client_pid}) do
    state = %{
      interval: interval,
      client_pid: client_pid
    }

    send(self(), :beat)
    {:ok, state}
  end

  def handle_info(:beat, state) do
    Process.send_after(self(), :beat, state.interval)
    #
    # TODO: Build & send payload
    #
    {:noreply, state}
  end
end
