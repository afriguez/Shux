defmodule Shux.Bot.Commands.Ticket do
  alias Shux.Bot.Components
  alias Shux.Discord.Api

  @behaviour Shux.Bot.Command

  def help() do
    %{
      usage: "sx!ticket",
      description: "Crea un boton para abrir tickets. Si se usa -p el boton sera persistente.",
      perms: :tech,
      options: ""
    }
  end

  def run(:admin, msg, ["-p"]) do
    Api.send_message(msg.channel_id, %{
      content: "",
      components: [
        Components.action_row([
          Components.button(
            style: 1,
            label: "Abrir Ticket",
            custom_id: "persistent_ticket",
            emoji: %{name: "🎟️", id: nil}
          )
        ])
      ]
    })

    {:ok, nil}
  end

  def run(:admin, msg, args), do: run(:tech, msg, args)

  def run(:tech, msg, _args) do
    Api.send_message(msg.channel_id, %{
      content: "",
      components: [
        Components.action_row([
          Components.button(
            style: 1,
            label: "Abrir Ticket",
            custom_id: "ticket",
            emoji: %{name: "🎟️", id: nil}
          )
        ])
      ]
    })

    {:ok, nil}
  end

  def run(_perms, _msg, _args), do: {:invalid, "Not authorized"}
end
