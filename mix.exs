defmodule Shux.MixProject do
  use Mix.Project

  def project do
    [
      app: :shux,
      version: "0.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Shux, []}
    ]
  end

  defp deps do
    [
      {:websockex, "~> 0.4.3"},
      {:poison, "~> 5.0"},
      {:httpoison, "~> 1.8.2"},
      {:image, "~> 0.38.2"},
      {:cachex, "~> 3.6.0"}
    ]
  end
end
