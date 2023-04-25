defmodule Shux.Bot.Handlers.InteractionHandler do
  alias Shux.Bot.Interactions

  @interactions %{
    avatar: Interactions.Avatar,
    member_avatar: Interactions.Avatar,
    ticket: Interactions.Ticket,
    close_ticket: Interactions.Ticket,
    persistent_ticket: Interactions.Ticket
  }

  def handle(data) do
    interaction = Map.get(@interactions, String.to_atom(data.data.custom_id))

    unless interaction == nil do
      interaction.run(data)
    end
  end
end
