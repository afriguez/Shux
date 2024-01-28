defmodule Shux.Bot.Easter do
  alias Shux.Discord.Api

  @asuka [
    "https://tenor.com/view/asuka-gif-20292417",
    "https://tenor.com/view/asuka-evangelion-irritated-bruh-gif-19369335",
    "https://tenor.com/view/feliz-jueves-asuka-feliz-jueves-asuka-jueves-gif-18184379",
    "https://tenor.com/view/shinji-asuka-neon-genesis-evangelion-smirk-anime-gif-15115499",
    "https://tenor.com/view/evangelion-neon-genesis-evangelion-neon-genesis-asuka-shinji-gif-19953445"
  ]

  @rei [
    "https://cdn.discordapp.com/attachments/728384734585028641/819412793001377792/156790385_913388956086172_2917913976425002494_o.png",
    "https://cdn.discordapp.com/attachments/728384734585028641/819414790727794728/2020-10-10_19.png",
    "https://cdn.discordapp.com/attachments/728384734585028641/819414869894889503/d20efd68-c5dc-442b-9ea4-3ca2b4c85583.png"
  ]

  def egg(%{content: "feliz jueves"} = msg) do
    cond do
      Date.utc_today() |> Date.day_of_week() != 4 ->
        nil

      probability(0.2) ->
        Api.send_message(msg.channel_id, Enum.random(@asuka))

      probability(0.01) ->
        Api.send_message(msg.channel_id, Enum.random(@rei))

      true ->
        nil
    end
  end

  def egg(_), do: nil

  defp probability(x) do
    :rand.uniform() < x
  end
end
