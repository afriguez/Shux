defmodule Shux.Bot.Interactions.Inventory do
  alias Shux.Bot.Components
  alias Shux.Bot.Leveling.LevelXpConverter
  alias Shux.Api
  alias Shux.Discord

  def run(interaction) do
    {:ok, user} = Api.get_user(interaction.guild_id, interaction.member.user.id)

    points = user.points
    colors = split_colors(points)
    response = run_inv(interaction, colors)

    Discord.Api.interaction_callback(interaction, response)
  end

  defp run_inv(%{data: %{custom_id: "list_colors"}}, colors) do
    embed = build_embed(colors)

    %{
      type: 7,
      data: %{
        embeds: [embed],
        components: [
          Components.action_row([
            Components.inventory_btn(),
            Components.list_colors_btn(true)
          ])
        ]
      }
    }
  end

  defp run_inv(_interaction, colors) do
    options =
      for color <- colors.unlocked do
        Components.string_option(
          label: color.name,
          value: color.id,
          emoji: %{
            id: "958174764969639956",
            name: "RoseBlasphemous"
          }
        )
      end

    fields =
      for color <- colors.unlocked do
        %{name: "Nivel #{color.level}", value: "<@&#{color.id}>", inline: true}
      end

    %{
      type: 7,
      data: %{
        embeds: [
          %{
            title: "Inventario de colores",
            color: 0xFFFFFF,
            fields: fields
          }
        ],
        components: [
          Components.action_row([
            Components.string_select(
              custom_id: "color_select",
              options: options,
              placeholder: "¿Quieres cambiar de color?"
            )
          ]),
          Components.action_row([
            Components.inventory_btn(true),
            Components.list_colors_btn()
          ])
        ]
      }
    }
  end

  defp split_colors(points) do
    Api.list_colors()
    |> Enum.reduce(%{locked: [], unlocked: []}, fn color, acc ->
      if LevelXpConverter.xp_to_level(points) >= color.level do
        %{acc | unlocked: [color | acc.unlocked]}
      else
        %{acc | locked: [color | acc.locked]}
      end
    end)
  end

  defp build_embed(colors) do
    unlocked =
      for color <- colors.unlocked do
        %{name: "Nivel #{color.level} ✅", value: "<@&#{color.id}>", inline: true}
      end

    locked =
      for color <- colors.locked do
        %{name: "Nivel #{color.level}", value: "<@&#{color.id}>", inline: true}
      end

    u_length = length(unlocked)
    l_length = length(locked)

    %{
      title: "Lista de colores",
      description: "Progreso: #{u_length}/#{l_length + u_length}",
      color: 0xFFFFFF,
      fields: unlocked ++ locked
    }
  end
end
