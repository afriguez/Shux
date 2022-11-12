defmodule Shux.Gateway.Heartbeat do
  use GenServer

  def start_link({_interval, _seq_num, _client_pid} = args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init({interval, seq_num, client_pid}) do
    state = %{
      interval: interval,
      seq_num: seq_num,
      client_pid: client_pid,
      ack?: true
    }

    send(self(), :beat)
    {:ok, state}
  end

  def handle_info({:ack, seq_num}, state) do
    {:noreply, %{state | ack?: true, seq_num: seq_num}}
  end

  def handle_info(:beat, state) do
    unless state.ack? do
      send(state.client_pid, :deadbeat)
    end

    payload = Poison.encode!(%{op: 1, d: state.seq_num})

    WebSockex.cast(
      state.client_pid,
      {:send, {:text, payload}}
    )

    Process.send_after(self(), :beat, state.interval)
    {:noreply, %{state | ack?: false}}
  end

  def ack(heartbeat_pid, seq_num) do
    send(heartbeat_pid, {:ack, seq_num})
  end
end
