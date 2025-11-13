defmodule ElixirPipelines do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Starting ElixirPipelines application...")

    children = [
      ElixirPipelines.PipelineRegistry,
      ElixirPipelines.PipelineLoader
    ]

    children = if Application.get_env(:elixir_pipelines, ElixirPipelines.Router)[:server] do
      children ++ [{Plug.Cowboy, scheme: :http, plug: ElixirPipelines.Router, options: [port: 9099]}]
    else
      children
    end

    opts = [strategy: :one_for_one, name: ElixirPipelines.Supervisor]
    result = Supervisor.start_link(children, opts)
    Logger.info("Supervisor started with result: #{inspect(result)}")
    result
  end
end
