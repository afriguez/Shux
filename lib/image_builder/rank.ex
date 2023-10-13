defmodule Shux.ImageBuilder.Rank do
  alias Shux.Bot.Leveling.LevelXpConverter

  def build(avatar, {username, points, level, rank}) do
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
    |> Image.write!(:memory, suffix: ".png")
  end

  defp compose_bar(img, points) do
    width_scale = LevelXpConverter.level_percentage(points)
    w = floor(397 * width_scale)
    h = 27

    bar =
      Image.new!(w, h, color: :white)
      |> Image.rounded!(radius: 14)

    Image.compose!(img, bar, x: 180, y: 63)
  end
end
