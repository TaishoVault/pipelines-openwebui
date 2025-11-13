defmodule PipelinesElixir do
  @moduledoc """
  Pipelines Elixir - A 1:1 Elixir port of the Python pipelines-openwebui project.
  
  This application provides a dynamic pipeline execution system with the following features:
  
  - **Dynamic Module Loading**: Runtime compilation and loading of Elixir modules
  - **Hot Reloading**: Automatic reloading of pipelines when files change
  - **RESTful API**: Complete API compatibility with the Python version
  - **Structured Logging**: Comprehensive logging with different levels and metadata
  - **Error Handling**: Robust error handling and reporting
  - **Authentication**: API key-based authentication
  - **CORS Support**: Cross-origin resource sharing for web applications
  
  ## Architecture
  
  The application consists of several key components:
  
  - `PipelinesElixir.Application`: Main application supervisor
  - `PipelinesElixir.PipelineLoader`: Dynamic module loading and execution
  - `PipelinesElixir.Web.Router`: HTTP API endpoints
  - `PipelinesElixir.Utils.Logger`: Enhanced logging utilities
  - `PipelinesElixir.Utils.Helpers`: Common utility functions
  
  ## Usage
  
  Start the application:
  
      mix run --no-halt
  
  Or in interactive mode:
  
      iex -S mix
  
  ## Configuration
  
  The application can be configured via environment variables:
  
  - `PIPELINES_API_KEY`: API key for authentication (default: "0p3n-w3bu!")
  - `PIPELINES_DIR`: Directory containing pipeline files (default: "./pipelines")
  - `PORT`: HTTP server port (default: 8000)
  - `HOST`: HTTP server host (default: "0.0.0.0")
  - `GLOBAL_LOG_LEVEL`: Logging level (default: "INFO")
  
  ## API Endpoints
  
  - `GET /`: Health check and API information
  - `GET /pipelines`: List all available pipelines
  - `GET /pipelines/:id`: Get specific pipeline information
  - `POST /pipelines/:id`: Execute a pipeline
  - `POST /pipelines/:id/update`: Reload a pipeline
  
  ## Pipeline Development
  
  Pipelines are Elixir modules that implement a `pipe/2` function:
  
      defmodule Pipeline.MyPipeline do
        @name "My Pipeline"
        @description "Description of what this pipeline does"
        @type "pipe"
        
        def pipe(body, user \\\\ nil) do
          # Process the input data
          # Return the result
        end
      end
  
  """

  @version "1.0.0"

  @doc """
  Returns the application version.
  """
  def version, do: @version

  @doc """
  Returns application information.
  """
  def info do
    %{
      name: "Pipelines Elixir",
      version: @version,
      description: "Dynamic pipeline execution system",
      author: "OpenHands AI",
      repository: "https://github.com/TaishoVault/pipelines-openwebui"
    }
  end

  @doc """
  Returns the current configuration.
  """
  def config do
    %{
      api_key: Application.get_env(:pipelines_elixir, :api_key),
      pipelines_dir: Application.get_env(:pipelines_elixir, :pipelines_dir),
      port: Application.get_env(:pipelines_elixir, :port),
      host: Application.get_env(:pipelines_elixir, :host),
      log_level: Logger.level()
    }
  end

  @doc """
  Checks if the application is running and healthy.
  """
  def health_check do
    try do
      # Check if the main processes are running
      pipeline_loader_running = Process.whereis(PipelinesElixir.PipelineLoader) != nil
      
      # Check if pipelines directory exists
      pipelines_dir = Application.get_env(:pipelines_elixir, :pipelines_dir, "./pipelines")
      pipelines_dir_exists = File.dir?(pipelines_dir)
      
      # Get pipeline count
      pipeline_count = case PipelinesElixir.PipelineLoader.list_pipelines() do
        {:ok, pipelines} -> length(pipelines)
        _ -> 0
      end
      
      %{
        status: "healthy",
        pipeline_loader_running: pipeline_loader_running,
        pipelines_dir_exists: pipelines_dir_exists,
        pipeline_count: pipeline_count,
        uptime: System.monotonic_time(:second),
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
      }
    rescue
      e ->
        %{
          status: "unhealthy",
          error: Exception.message(e),
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        }
    end
  end
end
