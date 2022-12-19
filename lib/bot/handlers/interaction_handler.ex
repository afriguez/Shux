defmodule Shux.Bot.Handlers.InteractionHandler do
  @interactions %{}

  def handle(data) do
    interaction = Map.get(@interactions, String.to_atom(data.data.custom_id))

    unless interaction == nil do
      interaction.run(data)
    end
  end
end
