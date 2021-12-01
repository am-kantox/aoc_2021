defmodule AoC_2021.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc_2021,
      version: "0.1.0",
      elixir: "~> 1.13-rc",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application, do: [extra_applications: [:logger]]
end
