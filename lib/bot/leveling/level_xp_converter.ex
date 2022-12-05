defmodule Shux.Bot.Leveling.LevelXpConverter do
  def xp_to_level(xp) do
    (2.5 * :math.sqrt(xp))
    |> round()
  end

  def level_to_xp(level) do
    (level / 2.5)
    |> :math.pow(2)
    |> round()
  end
end
