defmodule Shux.Bot.Interactions.Ticket do
  import Bitwise

  alias Shux.Bot.Components
  alias Shux.Discord.Api

  def run(interaction) do
    if interaction.data.custom_id == "close_ticket" do
      Api.delete_channel(interaction.channel_id)
    else
      {:ok, %{body: body}} =
        Api.create_channel(interaction.guild_id, %{
          name: interaction.member.user.id,
          type: 0,
          permission_overwrites: [
            %{
              id: interaction.member.user.id,
              type: 1,
              allow: Integer.to_string(0x400 ||| 0x800 ||| 0x4000 ||| 0x8000 ||| 0x10000)
            }
          ]
        })

      {:ok, %{id: channel_id}} = Poison.decode(body, %{keys: :atoms})

      Api.send_message(channel_id, %{
        content: "<@#{interaction.member.user.id}>",
        embeds: [
          %{
            description:
              "Recuerde enviar directamente el problema y specs del dispositivo.\n" <>
                "Si necesite ayuda con un presupuesto, especifique la moneda y el país\n\n" <>
                "*Por favor espere a que un técnico o administrador este disponible.*",
            color: random_color()
          }
        ],
        components: [
          Components.action_row([
            Components.button(
              style: 4,
              label: "Cerrar ticket",
              emoji: %{name: "🎫", id: nil},
              custom_id: "close_ticket"
            )
          ])
        ]
      })

      response =
        cond do
          interaction.data.custom_id == "persistent_ticket" ->
            %{
              type: 4,
              data: %{
                content: "**Ticket abierto:** <##{channel_id}>",
                flags: Integer.to_string(0x40)
              }
            }

          true ->
            %{
              type: 7,
              data: %{
                content: "**Ticket abierto:** <##{channel_id}>",
                components: []
              }
            }
        end

      Api.interaction_callback(interaction, response)
    end
  end

  def random_color, do: :math.floor(:rand.uniform() * 0xFFFFFF)
end
