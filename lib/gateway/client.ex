defmodule Shux.Gateway.Client do
  use WebSockex

  alias Shux.Gateway.Heartbeat

  @gateway_url "wss://gateway.discord.gg/?v=10&encoding=json"

  @opcodes %{
    # receive
    dispatch: 0,
    # send/receive
    heartbeat: 1,
    # send
    identify: 2,
    # send
    resume: 6,
    # receive
    reconnect: 7,
    # receive
    invalid_session: 9,
    # receive
    hello: 10,
    # receive
    heartbeat_ack: 11
  }

  def start_link(opts \\ []) do
    WebSockex.start_link(@gateway_url, __MODULE__, %{seq_num: nil, heartbeat_pid: nil}, opts)
  end

  def handle_connect(_conn, state) do
    {:ok, state}
  end

  def handle_disconnect(_connection_status_map, state) do
    {:ok, state}
  end

  def handle_frame({_type, payload}, state) do
    payload = Poison.Parser.parse!(payload, %{keys: :atoms})

    {opname, _opcode} =
      Enum.find(
        @opcodes,
        fn {_, v} ->
          v == payload.op
        end
      )

    handle_operation(opname, payload, state)
  end

  def handle_cast({:send, frame}, state) do
    {:reply, frame, state}
  end

  defp handle_operation(:hello, payload, state) do
    {:ok, pid} = Heartbeat.start_link({payload.d.heartbeat_interval, payload.s, self()})
    {:ok, %{state | heartbeat_pid: pid}}
  end

  defp handle_operation(:heartbeat_ack, _payload, state) do
    Heartbeat.ack(state.heartbeat_pid, state.seq_num)
    {:ok, state}
  end
end
