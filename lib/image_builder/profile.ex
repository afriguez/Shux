defmodule Shux.ImageBuilder.Profile do
  def build(avatar, {username, points, level, warns, desc}) do
    path = Path.join([:code.priv_dir(:shux), "assets", "profile_background.png"])
    {:ok, base_bg} = Image.open(path)
    {:ok, base_avatar} = Image.open(avatar)

    avatar = build_avatar(base_avatar)
    background = build_background(base_bg, {username, points, level, warns, desc})

    {:ok, image} = Image.compose(background, avatar, x: 25, y: 34)

    Image.write!(image, :memory, suffix: ".png")
  end

  def build_avatar(avatar) do
    width = Image.width(avatar)

    avatar
    |> Image.resize!(176 / width)
    |> Image.rounded!(radius: 15)
  end

  def build_background(base_bg, {username, points, level, warns, desc}) do
    font = "Poppins"

    {:ok, t_username} = Image.Text.text(username, font: font, font_size: 24)
    {:ok, t_points} = Image.Text.text("Puntos: " <> points, font: font, font_size: 18)
    {:ok, t_level} = Image.Text.text("Nivel: " <> level, font: font, font_size: 18)
    {:ok, t_warns} = Image.Text.text("Warns: " <> warns, font: font, font_size: 18)

    {:ok, t_desc} =
      Image.Text.text(
        desc,
        width: 320,
        height: 85,
        autofit: true,
        font: font
      )

    compose_text(
      [
        {t_username, 218, 34},
        {t_points, 218, 70},
        {t_level, 376, 70},
        {t_warns, 493, 70},
        {t_desc, 234, 118}
      ],
      base_bg
    )
    |> Image.rounded!(radius: 0)
  end

  def compose_text([], img), do: img

  def compose_text([{text, x, y} | text_list], img) do
    {:ok, img_with_text} = Image.compose(img, text, x: x, y: y)

    compose_text(text_list, img_with_text)
  end
end
