defmodule Shux.Bot.Leveling.LevelXpConverter do
  def xp_to_level(xp) do
    (2.5 * :math.sqrt(xp))
    |> floor()
  end

  def level_to_xp(level) do
    (level / 2.5)
    |> :math.pow(2)
    |> round()
  end

  def level_percentage(xp) do
    (2.5 * :math.sqrt(xp) - xp_to_level(xp))
    |> Float.round(2)
  end
end
