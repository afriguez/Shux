defmodule Shux.Bot.Interactions.Inventory do
  alias Shux.Bot.Components
  alias Shux.Bot.Leveling.LevelXpConverter
  alias Shux.Api
  alias Shux.Discord

  def run(%{data: %{custom_id: "color_select", values: [selection]}} = interaction) do
    {:ok, colors} = Api.get_colors(interaction.guild_id)
    %{roles: member_roles} = interaction.member

    ids_colors = Enum.reduce(colors, [], &[&1.id | &2])
    member_roles = member_roles -- ids_colors

    Discord.Api.update_member(interaction.guild_id, interaction.member.user.id, %{
      roles: member_roles ++ [selection]
    })

    Discord.Api.interaction_callback(interaction, %{
      type: 4,
      data: %{content: "Se han actualizado tus colores.", flags: 64}
    })
  end

  def run(interaction) do
    {:ok, user} = Api.get_user(interaction.guild_id, interaction.member.user.id)

    points = user.points
    colors = split_colors(interaction.guild_id, points)
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

  defp run_inv(_interaction, %{unlocked: []}) do
    %{
      type: 4,
      data: %{
        content: "Oops! No tienes colores",
        flags: 64
      }
    }
  end

  defp run_inv(%{data: %{custom_id: "inventory-edit"}}, colors) do
    {options, fields} = options_and_fields(colors)

    %{
      type: 7,
      data: basic_data(fields, options)
    }
  end

  defp run_inv(_interaction, colors) do
    {options, fields} = options_and_fields(colors)

    %{
      type: 4,
      data: basic_data(fields, options)
    }
  end

  defp basic_data(fields, options) do
    %{
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
      ],
      flags: 64
    }
  end

  defp options_and_fields(colors) do
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

    {options, fields}
  end

  defp split_colors(guild_id, points) do
    {:ok, colors} = Api.get_colors(guild_id)

    colors
    |> Enum.reduce(%{locked: [], unlocked: []}, fn color, acc ->
      IO.inspect(color)

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
