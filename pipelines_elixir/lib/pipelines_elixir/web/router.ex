defmodule PipelinesElixir.Web.Router do
  @moduledoc """
  Main HTTP router for the Pipelines Elixir application.
  
  This module defines all the HTTP routes and handles incoming requests.
  It provides a 1:1 API compatibility with the original Python pipelines server.
  
  ## Routes
  
  - GET / - Health check endpoint
  - GET /v1 - API version information
  - GET /models, /v1/models - List available models
  - GET /pipelines, /v1/pipelines - List all available pipelines
  - POST /pipelines/add, /v1/pipelines/add - Add a new pipeline
  - POST /pipelines/upload, /v1/pipelines/upload - Upload a pipeline file
  - DELETE /pipelines/delete, /v1/pipelines/delete - Delete a pipeline
  - POST /pipelines/reload, /v1/pipelines/reload - Reload a pipeline
  - GET /{pipeline_id}/valves, /v1/{pipeline_id}/valves - Get pipeline valves
  - GET /{pipeline_id}/valves/spec, /v1/{pipeline_id}/valves/spec - Get valve specifications
  - POST /{pipeline_id}/valves/update, /v1/{pipeline_id}/valves/update - Update pipeline valves
  - POST /{pipeline_id}/filter/inlet, /v1/{pipeline_id}/filter/inlet - Apply inlet filter
  - POST /{pipeline_id}/filter/outlet, /v1/{pipeline_id}/filter/outlet - Apply outlet filter
  - POST /chat/completions, /v1/chat/completions - OpenAI-compatible chat completions endpoint
  """
  
  use Plug.Router
  
  alias PipelinesElixir.PipelineLoader
  
  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  # Health check endpoint
  get "/" do
    response = %{
      status: "ok",
      message: "Pipelines Elixir Server",
      version: "1.0.0"
    }
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(response))
  end

  # API version information
  get "/v1" do
    require Logger
    Logger.info("GET /v1")
    
    response = %{
      status: "ok",
      message: "Pipelines Elixir Server v1 API",
      version: "1.0.0"
    }
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(response))
  end

  # List available models (both /models and /v1/models)
  get "/models" do
    handle_models_request(conn)
  end

  get "/v1/models" do
    handle_models_request(conn)
  end

  # List all pipelines (both /pipelines and /v1/pipelines)
  get "/pipelines" do
    handle_list_pipelines(conn)
  end

  get "/v1/pipelines" do
    handle_list_pipelines(conn)
  end

  # Add a new pipeline (both /pipelines/add and /v1/pipelines/add)
  post "/pipelines/add" do
    handle_add_pipeline(conn)
  end

  post "/v1/pipelines/add" do
    handle_add_pipeline(conn)
  end

  # Upload a pipeline file (both /pipelines/upload and /v1/pipelines/upload)
  post "/pipelines/upload" do
    handle_upload_pipeline(conn)
  end

  post "/v1/pipelines/upload" do
    handle_upload_pipeline(conn)
  end

  # Delete a pipeline (both /pipelines/delete and /v1/pipelines/delete)
  delete "/pipelines/delete" do
    handle_delete_pipeline(conn)
  end

  delete "/v1/pipelines/delete" do
    handle_delete_pipeline(conn)
  end

  # Reload a pipeline (both /pipelines/reload and /v1/pipelines/reload)
  post "/pipelines/reload" do
    handle_reload_pipeline(conn)
  end

  post "/v1/pipelines/reload" do
    handle_reload_pipeline(conn)
  end

  # Get pipeline valves
  get "/:pipeline_id/valves" do
    handle_get_valves(conn, pipeline_id)
  end

  get "/v1/:pipeline_id/valves" do
    handle_get_valves(conn, pipeline_id)
  end

  # Get valve specifications
  get "/:pipeline_id/valves/spec" do
    handle_get_valves_spec(conn, pipeline_id)
  end

  get "/v1/:pipeline_id/valves/spec" do
    handle_get_valves_spec(conn, pipeline_id)
  end

  # Update pipeline valves
  post "/:pipeline_id/valves/update" do
    handle_update_valves(conn, pipeline_id)
  end

  post "/v1/:pipeline_id/valves/update" do
    handle_update_valves(conn, pipeline_id)
  end

  # Apply inlet filter
  post "/:pipeline_id/filter/inlet" do
    handle_inlet_filter(conn, pipeline_id)
  end

  post "/v1/:pipeline_id/filter/inlet" do
    handle_inlet_filter(conn, pipeline_id)
  end

  # Apply outlet filter
  post "/:pipeline_id/filter/outlet" do
    handle_outlet_filter(conn, pipeline_id)
  end

  post "/v1/:pipeline_id/filter/outlet" do
    handle_outlet_filter(conn, pipeline_id)
  end

  # OpenAI-compatible chat completions endpoint
  post "/chat/completions" do
    handle_chat_completions(conn)
  end

  post "/v1/chat/completions" do
    handle_chat_completions(conn)
  end

  # Catch-all for unmatched routes
  match _ do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path} - Not Found")
    
    response = %{
      error: "Not Found",
      message: "The requested endpoint does not exist"
    }
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(response))
  end

  # Private helper functions

  defp handle_models_request(conn) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    # Get all pipelines and convert them to model format
    pipelines = PipelineLoader.list_pipelines()
    
    models = Enum.map(pipelines, fn pipeline ->
      %{
        id: pipeline.id,
        object: "model",
        created: System.system_time(:second),
        owned_by: "pipelines-elixir"
      }
    end)
    
    response = %{
      object: "list",
      data: models
    }
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(response))
  end

  defp handle_list_pipelines(conn) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    pipelines = PipelineLoader.list_pipelines()
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(pipelines))
  end

  defp handle_add_pipeline(conn) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case conn.body_params do
      %{"url" => url} ->
        case PipelineLoader.add_pipeline_from_url(url) do
          {:ok, pipeline_id} ->
            response = %{
              status: "success",
              message: "Pipeline added successfully",
              pipeline_id: pipeline_id
            }
            
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(response))
          
          {:error, reason} ->
            response = %{
              status: "error",
              message: "Failed to add pipeline: #{reason}"
            }
            
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Jason.encode!(response))
        end
      
      _ ->
        response = %{
          status: "error",
          message: "Missing required parameter: url"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end

  defp handle_upload_pipeline(conn) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    # TODO: Implement file upload handling
    response = %{
      status: "error",
      message: "File upload not yet implemented"
    }
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(501, Jason.encode!(response))
  end

  defp handle_delete_pipeline(conn) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case conn.body_params do
      %{"id" => pipeline_id} ->
        case PipelineLoader.delete_pipeline(pipeline_id) do
          :ok ->
            response = %{
              status: "success",
              message: "Pipeline deleted successfully"
            }
            
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(response))
          
          {:error, reason} ->
            response = %{
              status: "error",
              message: "Failed to delete pipeline: #{reason}"
            }
            
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Jason.encode!(response))
        end
      
      _ ->
        response = %{
          status: "error",
          message: "Missing required parameter: id"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end

  defp handle_reload_pipeline(conn) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case conn.body_params do
      %{"id" => pipeline_id} ->
        case PipelineLoader.reload_pipeline(pipeline_id) do
          :ok ->
            response = %{
              status: "success",
              message: "Pipeline reloaded successfully"
            }
            
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(response))
          
          {:error, reason} ->
            response = %{
              status: "error",
              message: "Failed to reload pipeline: #{reason}"
            }
            
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Jason.encode!(response))
        end
      
      _ ->
        response = %{
          status: "error",
          message: "Missing required parameter: id"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end

  defp handle_get_valves(conn, pipeline_id) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case PipelineLoader.get_pipeline_valves(pipeline_id) do
      {:ok, valves} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(valves))
      
      {:error, reason} ->
        response = %{
          status: "error",
          message: "Failed to get valves: #{reason}"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end

  defp handle_get_valves_spec(conn, pipeline_id) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case PipelineLoader.get_pipeline_valves_spec(pipeline_id) do
      {:ok, spec} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(spec))
      
      {:error, reason} ->
        response = %{
          status: "error",
          message: "Failed to get valves spec: #{reason}"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end

  defp handle_update_valves(conn, pipeline_id) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case PipelineLoader.update_pipeline_valves(pipeline_id, conn.body_params) do
      :ok ->
        response = %{
          status: "success",
          message: "Valves updated successfully"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(response))
      
      {:error, reason} ->
        response = %{
          status: "error",
          message: "Failed to update valves: #{reason}"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end

  defp handle_inlet_filter(conn, pipeline_id) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case PipelineLoader.apply_inlet_filter(pipeline_id, conn.body_params) do
      {:ok, result} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(result))
      
      {:error, reason} ->
        response = %{
          status: "error",
          message: "Failed to apply inlet filter: #{reason}"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end

  defp handle_outlet_filter(conn, pipeline_id) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case PipelineLoader.apply_outlet_filter(pipeline_id, conn.body_params) do
      {:ok, result} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(result))
      
      {:error, reason} ->
        response = %{
          status: "error",
          message: "Failed to apply outlet filter: #{reason}"
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end

  defp handle_chat_completions(conn) do
    require Logger
    Logger.info("#{conn.method} #{conn.request_path}")
    
    case conn.body_params do
      %{"model" => model} = params ->
        case PipelineLoader.execute_pipeline(model, params) do
          {:ok, result} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(result))
          
          {:error, reason} ->
            response = %{
              error: %{
                message: "Failed to execute pipeline: #{reason}",
                type: "pipeline_error",
                code: "pipeline_execution_failed"
              }
            }
            
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Jason.encode!(response))
        end
      
      _ ->
        response = %{
          error: %{
            message: "Missing required parameter: model",
            type: "invalid_request_error",
            code: "missing_parameter"
          }
        }
        
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(response))
    end
  end
end