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
    name =
      if Map.get(data.data, :custom_id) != nil do
        String.to_atom(data.data.custom_id)
      else
        String.to_atom(String.downcase(data.data.name))
      end

    interaction = Map.get(@interactions, name)

    unless interaction == nil do
      interaction.run(data)
    end
  end
end
