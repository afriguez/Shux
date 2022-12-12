defmodule Shux.Discord.Gateway.Client do
  use WebSockex

  alias Shux.Discord.Gateway.Heartbeat
  alias Shux.Bot.Handlers.MessageHandler
  alias Shux.Bot.Handlers.InteractionHandler

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
    identify()
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

  def handle_info(:deadbeat, state) do
    {:close, state}
  end

  defp handle_operation(:hello, payload, state) do
    {:ok, pid} = Heartbeat.start_link({payload.d.heartbeat_interval, payload.s, self()})
    {:ok, %{state | heartbeat_pid: pid}}
  end

  defp handle_operation(:heartbeat_ack, _payload, state) do
    Heartbeat.ack(state.heartbeat_pid, state.seq_num)
    {:ok, state}
  end

  defp handle_operation(:reconnect, _payload, state) do
    {:close, state}
  end

  defp handle_operation(:invalid_session, _payload, state) do
    {:close, state}
  end

  defp handle_operation(:dispatch, payload, state) do
    event = String.to_atom(payload.t)
    IO.inspect(event)

    handle_event(event, payload.d)
    {:ok, state}
  end

  defp handle_event(:MESSAGE_CREATE, data) do
    MessageHandler.handle(data)
  end

  defp handle_event(:MESSAGE_UPDATE, data) do
    MessageHandler.handle(data, :edited)
  end

  defp handle_event(:MESSAGE_DELETE, data) do
    MessageHandler.handle(data, :deleted)
  end

  defp handle_event(:INTERACTION_CREATE, data) do
    InteractionHandler.handle(data)
  end

  defp handle_event(_event, _data) do
  end

  def identify do
    payload =
      Poison.encode!(%{
        op: @opcodes[:identify],
        d: %{
          token: Application.get_env(:shux, :bot_token),
          intents: 34305,
          compress: false,
          properties: %{
            os: "linux",
            browser: "shux",
            device: "shux"
          },
          presence: %{
            activities: [
              %{
                name: "Not a Number",
                type: 0
              }
            ],
            status: "online",
            afk: false
          }
        }
      })

    WebSockex.cast(self(), {:send, {:text, payload}})
  end
end
