defmodule Shux.ImageBuilder.Leaderboard do
  def build(users) when is_list(users) do
    users
    |> get_avatars()
    |> compose_leaderboard()
    |> compose_text(users)
    |> Image.write!(:memory, suffix: ".png")
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

  defp make_texts(users) do
    # { t_username, t_points, t_level }
    font = "Poppins"

    texts_pos = [
      {303, 148},
      {121, 205},
      {481, 205},
      {139, 322},
      {377, 322}
    ]

    Enum.zip(users, texts_pos)
    |> Enum.with_index()
    |> Enum.reduce([], fn {{{_, username, points, level}, {x, y}}, i}, acc ->
      font_size = if i <= 2, do: 18, else: 14

      [
        {Image.Text.text!(
           username,
           font: font,
           font_size: font_size,
           font_weight: 600
         ),
         Image.Text.text!(
           "Puntos: #{floor(points)}",
           font: font,
           font_size: 10,
           font_weight: 600
         ),
         Image.Text.text!(
           "Nivel: #{level}",
           font: font,
           font_size: 10,
           font_weight: 600
         ), x, y}
        | acc
      ]
    end)
    |> Enum.reverse()
  end

  defp compose_text(leaderboard, users) do
    make_texts(users)
    |> Enum.with_index()
    |> Enum.reduce(leaderboard, fn {{t_username, t_points, t_level, x, y}, i}, acc ->
      h_username = Image.height(t_username) + 5
      h_points = Image.height(t_points) + h_username + 5

      {x_u, x_p, x_l} =
        if i <= 2 do
          {
            (x - Image.width(t_username) / 2) |> floor(),
            (x - Image.width(t_points) / 2) |> floor(),
            (x - Image.width(t_level) / 2) |> floor()
          }
        else
          {x, x, x}
        end

      Image.compose!(acc, t_username, x: x_u, y: y)
      |> Image.compose!(t_points, x: x_p, y: y + h_username)
      |> Image.compose!(t_level, x: x_l, y: y + h_points)
    end)
  end

  defp compose_avatars([], img), do: img

  defp compose_avatars([{avatar, x, y, size} | tail], img) do
    {:ok, avatar} = Image.resize(avatar, size / Image.width(avatar))
    {:ok, img} = Image.compose(img, avatar, x: x, y: y)

    compose_avatars(tail, img)
  end
end
