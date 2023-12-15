defmodule Shux.ApiSessionScheduler do
  use GenServer

  alias Shux.Api
  alias Shux.Discord.Cache

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(_args) do
    send(self(), :refresh)
    state = %{timer_ref: nil, access_token: nil, refresh_token: nil}
    {:ok, state}
  end

  def handle_info(:refresh, state) do
    {access_token, refresh_token} =
      if state.timer_ref do
        Process.cancel_timer(state.timer_ref)
        Api.refresh(state.refresh_token)
      else
        Api.login()
      end

    Cache.put_tokens({access_token, refresh_token})

    timer_ref = Process.send_after(self(), :refresh, 19 * 60_000)

    {:noreply,
     %{
       state
       | timer_ref: timer_ref,
         access_token: access_token,
         refresh_token: refresh_token
     }}
  end
end
