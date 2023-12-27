defmodule Shux.Bot.Interactions.Ticket do
  alias Shux.Bot.Components
  alias Shux.Discord.Api
  alias Shux.Discord.BitValues

  def run(%{data: %{custom_id: "close_ticket"}} = interaction) do
    Api.delete_channel(interaction.channel_id)
    Shux.Api.delete_ticket(interaction.guild_id, interaction.channel_id)
  end

  def run(interaction) do
    user_id = interaction.member.user.id
    guild_id = interaction.guild_id

    {:ok, tickets} = Shux.Api.get_tickets(guild_id)
    has_ticket? = Map.has_key?(tickets, user_id)

    if has_ticket? do
      Api.interaction_callback(
        interaction,
        %{
          type: 4,
          data: %{
            content: "Ya tienes un ticket abierto: <##{tickets[user_id]}>",
            flags: "#{0x40}"
          }
        }
      )
    else
      %{id: channel_id} = create_ticket(guild_id, user_id)
      send_ticket_message(channel_id, user_id)

      {:ok, %{tickets: ticket_count}} = update_ticket_count(guild_id, user_id)

      Api.interaction_callback(
        interaction,
        ticket_created_response(interaction, ticket_count, channel_id)
      )

      Shux.Api.post_ticket(guild_id, user_id, channel_id)
    end
  end

  defp update_ticket_count(guild_id, user_id) do
    {:ok, %{tickets: tickets}} = Shux.Api.get_user(guild_id, user_id)
    Shux.Api.update_user(guild_id, user_id, %{tickets: tickets + 1})
  end

  defp create_ticket(guild_id, user_id) do
    bit_value =
      BitValues.value_of(:permissions, [
        :view_channel,
        :send_messages,
        :embed_links,
        :attach_files,
        :read_message_history
      ])

    {:ok, tickets_category} = Shux.Api.get_tickets_category(guild_id)

    {:ok, %{roles: roles}} = Shux.Api.get_roles(guild_id)
    role_flags = Shux.Api.get_role_flags()

    tech_overwrites =
      roles
      |> Shux.Api.filter_by_flags(role_flags.tech)
      |> Enum.map(fn role -> %{id: role.id, type: 0, allow: bit_value} end)

    {:ok, res} =
      Api.create_channel(guild_id, %{
        name: user_id,
        type: 0,
        parent_id: tickets_category.id,
        permission_overwrites:
          [
            %{id: user_id, type: 1, allow: bit_value},
            %{id: guild_id, type: 0, deny: BitValues.value_of(:permissions, [:view_channel])}
          ] ++ tech_overwrites
      })

    Poison.decode!(res.body, %{keys: :atoms})
  end

  defp send_ticket_message(channel_id, user_id) do
    Api.send_message(channel_id, %{
      content: "<@#{user_id}>",
      embeds: [
        %{
          description:
            "Recuerde enviar directamente el problema y specs del dispositivo.\n" <>
              "Si necesita ayuda con un presupuesto, especifique la moneda y el país\n\n" <>
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
  end

  defp ticket_created_response(interaction, ticket_count, channel_id) do
    cond do
      interaction.data.custom_id == "persistent_ticket" ->
        %{
          type: 4,
          data: %{
            content:
              "**Ticket abierto:** <##{channel_id}>\nHas abierto un total de **#{ticket_count}** tickets!",
            flags: "#{0x40}"
          }
        }

      true ->
        %{
          type: 7,
          data: %{
            content:
              "**Ticket abierto:** <##{channel_id}>\nHas abierto un total de **#{ticket_count}** tickets!",
            components: []
          }
        }
    end
  end

  def random_color, do: :math.floor(:rand.uniform() * 0xFFFFFF)
end
