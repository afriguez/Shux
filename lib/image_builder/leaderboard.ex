defmodule Shux.ImageBuilder.Leaderboard do
  def build(users) when is_list(users) do
    users
    |> get_avatars()
    |> compose_leaderboard()
    |> compose_text(users)
  end

  defp get_avatars(users) do
    users
    |> Enum.reduce([], fn {avatar, _, _, _}, acc -> [Image.open!(avatar) | acc] end)
    |> Enum.reverse()
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

    for {{x, y, size}, avatar} <- Enum.zip(pos_and_sizes, avatars) do
      {avatar, x, y, size}
    end
    |> compose_avatars(transparent_bg)
    |> Image.compose!(leaderboard_bg)
  end

  defp compose_text(leaderboard, _users) do
    Image.write!(leaderboard, :memory, suffix: ".png")
  end

  defp compose_avatars([], img), do: img

  defp compose_avatars([{avatar, x, y, size} | tail], img) do
    {:ok, avatar} = Image.resize(avatar, size / Image.width(avatar))
    {:ok, img} = Image.compose(img, avatar, x: x, y: y)

    compose_avatars(tail, img)
  end
end
