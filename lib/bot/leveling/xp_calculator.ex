defmodule Shux.Bot.Leveling.XpCalculator do
  def calculate(len) when is_integer(len) do
    max = len * 1.1
    min = len * 0.9

    ((:rand.uniform() * (max - min) + min) * 0.003)
    |> :rand.normal(0.03)
    |> abs()
  end

  def calculate(content) when is_binary(content) do
    String.length(content)
    |> calculate()
  end
end
