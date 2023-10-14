defmodule Shux.Bot.Interactions.Rank do
  import Bitwise

  alias Shux.Api
  alias Shux.Discord

  def run(interaction) do
    response = run_rank(interaction)
    Discord.Api.interaction_callback(interaction, response)
  end

  def run_rank(%{data: %{custom_id: "rank_position"}, member: member}) do
    user = member.user
    rank = Api.get_rank!(user.id)

    %{
      type: 4,
      data: %{
        content: "Estas en el rango **##{rank}**",
        flags: 1 <<< 6
      }
    }
  end
end
