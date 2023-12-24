defmodule Shux.Bot.Handlers.InteractionHandler do
  alias Shux.Bot.Interactions

  @interactions %{
    avatar: Interactions.Avatar,
    member_avatar: Interactions.Avatar,
    profile_avatar: Interactions.Avatar,
    banner: Interactions.Banner,
    ticket: Interactions.Ticket,
    close_ticket: Interactions.Ticket,
    persistent_ticket: Interactions.Ticket,
    description: Interactions.Description,
    update_description: Interactions.Description,
    rank_position: Interactions.Rank,
    rank: Interactions.Rank,
    profile: Interactions.Profile,
    inventory: Interactions.Inventory,
    list_colors: Interactions.Inventory,
    color_select: Interactions.Inventory,
    role: Interactions.Role
  }

  def handle(data) do
    name =
      if Map.get(data.data, :custom_id) != nil do
        data.data.custom_id
      else
        String.downcase(data.data.name)
      end

    [h | _t] = String.split(name, "-")
    name = String.to_atom(h)

    interaction = Map.get(@interactions, name)

    unless interaction == nil do
      interaction.run(data)
    end
  end
end
