defmodule PipelinesElixir.Application do
  @moduledoc """
  Main application module for Pipelines Elixir.
  
  This is the entry point for the Pipelines Elixir application, providing a 1:1 port
  of the Python open-webui/pipelines project. It manages the supervision tree and
  coordinates all core components:
  
  ## Components
  - **PipelineLoader**: GenServer for dynamic module loading and pipeline management
  - **CowboyServer**: HTTP server providing REST API endpoints for pipeline operations
  
  ## Configuration
  The application reads configuration from environment variables:
  - `PORT`: HTTP server port (default: 9090)
  - `HOST`: Server host binding (default: "0.0.0.0")
  - `PIPELINES_DIR`: Directory containing pipeline modules (default: "./pipelines")
  
  ## Features
  - Dynamic runtime loading of Elixir pipeline modules
  - Complete API compatibility with Python pipelines server
  - Comprehensive logging and error handling
  - Fault-tolerant supervision tree with automatic restarts
  """

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    # Read configuration from environment variables at runtime
    # This allows deployment-time configuration without recompilation
    port = System.get_env("PORT", "8000") |> String.to_integer()
    host = System.get_env("HOST", "0.0.0.0")
    pipelines_dir = System.get_env("PIPELINES_DIR", "./pipelines")

    Logger.info("Starting Pipelines Elixir server on #{host}:#{port}")
    Logger.info("Pipelines directory: #{pipelines_dir}")

    # Ensure the pipelines directory exists for dynamic module loading
    File.mkdir_p!(pipelines_dir)

    # Define the supervision tree with ordered startup
    # PipelineLoader must start first as CowboyServer depends on it
    children = [
      # GenServer managing dynamic pipeline loading, execution, and lifecycle
      {PipelinesElixir.PipelineLoader, pipelines_dir: pipelines_dir},
      
      # HTTP server providing REST API endpoints compatible with Python pipelines
      {PipelinesElixir.Web.CowboyServer, port: port}
    ]

    # Use one_for_one supervision strategy for fault isolation
    # If one child crashes, only that child is restarted, maintaining service availability
    opts = [strategy: :one_for_one, name: PipelinesElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Parse IP address string to tuple format
  defp parse_ip(host) when is_binary(host) do
    case :inet.parse_address(String.to_charlist(host)) do
      {:ok, ip} -> ip
      {:error, _} -> {0, 0, 0, 0}  # Default to 0.0.0.0
    end
  end
end
