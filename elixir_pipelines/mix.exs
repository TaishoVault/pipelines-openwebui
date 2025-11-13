defmodule ElixirPipelines.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_pipelines,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      config_path: "config/config.exs",
      test_config_path: "config/test.exs"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ElixirPipelines, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.4"}
    ]
  end
end
