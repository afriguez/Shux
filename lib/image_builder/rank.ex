defmodule Shux.ImageBuilder.Rank do
  alias Shux.Bot.Leveling.LevelXpConverter

  def build(avatar, {_, points, _, _} = props) do
    path = Path.join([:code.priv_dir(:shux), "assets", "rank.png"])
    {:ok, rank_bg} = Image.open(path)
    {:ok, avatar} = Image.open(avatar)

    w = Image.width(rank_bg)
    h = Image.height(rank_bg)

    transparent_bg = Image.new!(w, h, color: [0, 0, 0, 0], bands: 4)

    {:ok, avatar} = Image.resize(avatar, 139 / Image.width(avatar))

    Image.compose!(transparent_bg, avatar, x: 19, y: 5)
    |> Image.compose!(rank_bg)
    |> compose_bar(points)
    |> compose_text(props)
    |> Image.write!(:memory, suffix: ".png")
  end

  defp compose_bar(img, points) do
    width_scale = LevelXpConverter.level_percentage(points)

    if width_scale == 0 do
      img
    else
      w = floor(397 * width_scale)
      w = if w < 10, do: 10, else: w
      h = 27

      bar =
        Image.new!(w, h, color: :white)
        |> Image.rounded!(radius: 14)

      Image.compose!(img, bar, x: 180, y: 63)
    end
  end

  defp compose_text(img, {username, points, level, rank}) do
    font = "Poppins"
    points = floor(points)

    points = Integer.to_string(points)
    level = Integer.to_string(level)
    rank = Integer.to_string(rank)

    {:ok, t_username} =
      Image.Text.text(username,
        font: font,
        font_size: 22,
        text_fill_color: :black,
        font_weight: 600
      )

    {:ok, t_points} =
      Image.Text.text("Puntos: " <> points,
        font: font,
        font_size: 18,
        text_fill_color: :black,
        font_weight: 600
      )

    {:ok, t_level} =
      Image.Text.text("Nivel: " <> level,
        font: font,
        font_size: 18,
        text_fill_color: :black,
        font_weight: 600
      )

    {:ok, t_rank} =
      Image.Text.text("#" <> rank,
        font: font,
        font_size: 30,
        text_fill_color: :black,
        font_weight: 600
      )

    [
      {t_username, 184, 26},
      {t_points, 184, 101},
      {t_level, 326, 101},
      {t_rank, 494, 26}
    ]
    |> Enum.reduce(img, fn {text, x, y}, acc ->
      Image.compose!(acc, text, x: x, y: y)
    end)
  end
end
