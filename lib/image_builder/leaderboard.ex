defmodule Shux.ImageBuilder.Leaderboard do
  def build(avatars) when is_list(avatars) do
    avatars
    |> Enum.reduce([], &[Image.open!(&1) | &2])
    |> Enum.reverse()
    |> compose_leaderboard()
  end

  defp compose_leaderboard(avatars) do
    path = Path.join([:code.priv_dir(:shux), "assets", "leaderboard.png"])
    {:ok, leaderboard_bg} = Image.open(path)

    w = Image.width(leaderboard_bg)
    h = Image.height(leaderboard_bg)

    transparent_bg = Image.new!(w, h, color: [0, 0, 0, 0], bands: 4)

    pos_and_sizes = [
      {262, 38, 85},
      {81, 95, 85},
      {441, 95, 85},
      {84, 316, 50},
      {322, 316, 50}
    ]

    leaderboard =
      for {{x, y, size}, avatar} <- Enum.zip(pos_and_sizes, avatars) do
        {avatar, x, y, size}
      end
      |> compose_avatars(transparent_bg)
      |> Image.compose!(leaderboard_bg)

    Image.write!(leaderboard, :memory, suffix: ".png")
  end

  defp compose_avatars([], img), do: img

  defp compose_avatars([{avatar, x, y, size} | tail], img) do
    {:ok, avatar} = Image.resize(avatar, size / Image.width(avatar))
    {:ok, img} = Image.compose(img, avatar, x: x, y: y)

    compose_avatars(tail, img)
  end
end
