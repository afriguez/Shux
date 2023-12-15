defmodule Shux.Bot.Commands.Inventory do
  alias Shux.Bot.Leveling.LevelXpConverter
  alias Shux.Bot.Components
  alias Shux.Api
  alias Shux.Discord

  @behaviour Shux.Bot.Command

  def help() do
    %{
      usage: "sx!inv @user",
      description: "Muestra el inventario de colores.",
      perms: :user,
      options: ""
    }
  end

  def run(_perms, msg, _args) do
    user = if Enum.empty?(msg.mentions), do: msg.author, else: hd(msg.mentions)
    api_user = Api.get_user(msg.guild_id, user.id)

    points = api_user.points
    colors = filter_colors(points)
    message = build_message(colors)

    Discord.Api.send_message(msg.channel_id, message)

    {:ok, nil}
  end

  defp filter_colors(points) do
    Api.list_colors!()
    |> Enum.reduce(%{locked: [], unlocked: []}, fn color, acc ->
      if LevelXpConverter.xp_to_level(points) >= color.level do
        %{acc | unlocked: [color | acc.unlocked]}
      else
        %{acc | locked: [color | acc.locked]}
      end
    end)
  end

  defp build_message(%{unlocked: []}), do: %{content: "Oops! No tienes colores."}

  defp build_message(%{unlocked: unlocked}) do
    options = build_options(unlocked)
    fields = build_fields(unlocked, [])

    %{
      embeds: [
        %{
          title: "Inventario de colores",
          color: :math.floor(0xFFFFFF),
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
  end

  defp build_options(unlocked) do
    for color <- unlocked do
      Components.string_option(
        label: color.name,
        value: color.id,
        emoji: %{
          id: "958174764969639956",
          name: "RoseBlasphemous"
        }
      )
    end
  end

  defp build_fields([], fields), do: fields

  defp build_fields([color | t], fields) do
    field = %{value: "<@&#{color.id}>", name: "Nivel #{color.level}", inline: true}

    build_fields(t, [field | fields])
  end
end
