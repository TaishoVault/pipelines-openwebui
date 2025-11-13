defmodule PipelinesElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :pipelines_elixir,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :crypto],
      mod: {PipelinesElixir.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Minimal web server
      {:plug_cowboy, "~> 2.7"},
      {:plug, "~> 1.16"},
      
      # JSON handling
      {:jason, "~> 1.4"},
      
      # File system watching for dynamic loading
      {:file_system, "~> 1.0"}
    ]
  end
end
