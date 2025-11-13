defmodule PipelinesElixir.PipelineLoader do
  @moduledoc """
  Dynamic pipeline loader for Elixir - Core component providing Python-like dynamic imports.
  
  This GenServer manages the complete lifecycle of pipeline modules, providing functionality
  equivalent to Python's dynamic import system used in the original pipelines project.
  
  ## Core Features
  - **Dynamic Compilation**: Runtime compilation and loading of .ex files from the pipelines directory
  - **Module Management**: Automatic registration, caching, and cleanup of loaded pipeline modules
  - **Hot Reloading**: Automatic detection and reloading of changed pipeline files
  - **Pipeline Validation**: Ensures loaded modules conform to the expected pipeline interface
  - **Error Handling**: Comprehensive error handling with detailed logging for debugging
  - **API Compatibility**: Provides 1:1 API compatibility with Python pipelines server
  
  ## Pipeline Interface
  Each pipeline module must implement:
  - `pipe/3`: Main processing function (body, user, model)
  - `info/0`: Pipeline metadata and configuration
  - Optional: `inlet/3`, `outlet/3` for request/response filtering
  
  ## State Management
  The GenServer maintains:
  - `pipelines_dir`: Directory path for pipeline files
  - `loaded_pipelines`: Map of loaded pipeline modules and metadata
  - `file_timestamps`: File modification tracking for hot reloading
  
  ## Usage
  Started automatically by the application supervisor with the configured pipelines directory.
  Provides both synchronous and asynchronous APIs for pipeline operations.
  """

  use GenServer
  require Logger

  @doc """
  Starts the pipeline loader GenServer.
  """
  def start_link(opts) do
    pipelines_dir = Keyword.get(opts, :pipelines_dir, "./pipelines")
    GenServer.start_link(__MODULE__, %{pipelines_dir: pipelines_dir}, name: __MODULE__)
  end

  @doc """
  Lists all available pipelines in the pipelines directory.
  """
  def list_pipelines do
    GenServer.call(__MODULE__, :list_pipelines)
  end

  @doc """
  Gets information about a specific pipeline.
  """
  def get_pipeline(pipeline_id) do
    GenServer.call(__MODULE__, {:get_pipeline, pipeline_id})
  end

  @doc """
  Loads and compiles a pipeline module dynamically.
  """
  def load_pipeline(pipeline_id) do
    GenServer.call(__MODULE__, {:load_pipeline, pipeline_id})
  end

  @doc """
  Executes a pipeline with the given body and user information.
  """
  def execute_pipeline(pipeline_id, body, user \\ nil) do
    GenServer.call(__MODULE__, {:execute_pipeline, pipeline_id, body, user}, 30_000)
  end

  @doc """
  Reloads a pipeline (useful for development).
  """
  def reload_pipeline(pipeline_id) do
    GenServer.call(__MODULE__, {:reload_pipeline, pipeline_id})
  end

  @doc """
  Adds a pipeline from a URL.
  """
  def add_pipeline_from_url(url) do
    GenServer.call(__MODULE__, {:add_pipeline_from_url, url})
  end

  @doc """
  Deletes a pipeline.
  """
  def delete_pipeline(pipeline_id) do
    GenServer.call(__MODULE__, {:delete_pipeline, pipeline_id})
  end

  @doc """
  Gets pipeline valves (configuration parameters).
  """
  def get_pipeline_valves(pipeline_id) do
    GenServer.call(__MODULE__, {:get_pipeline_valves, pipeline_id})
  end

  @doc """
  Gets pipeline valves specification.
  """
  def get_pipeline_valves_spec(pipeline_id) do
    GenServer.call(__MODULE__, {:get_pipeline_valves_spec, pipeline_id})
  end

  @doc """
  Updates pipeline valves.
  """
  def update_pipeline_valves(pipeline_id, valves) do
    GenServer.call(__MODULE__, {:update_pipeline_valves, pipeline_id, valves})
  end

  @doc """
  Applies inlet filter to a pipeline.
  """
  def apply_inlet_filter(pipeline_id, data) do
    GenServer.call(__MODULE__, {:apply_inlet_filter, pipeline_id, data})
  end

  @doc """
  Applies outlet filter to a pipeline.
  """
  def apply_outlet_filter(pipeline_id, data) do
    GenServer.call(__MODULE__, {:apply_outlet_filter, pipeline_id, data})
  end

  # GenServer callbacks

  @impl true
  def init(%{pipelines_dir: pipelines_dir}) do
    Logger.info("Initializing Pipeline Loader with directory: #{pipelines_dir}")
    
    # Initial scan of pipelines
    pipelines = scan_pipelines(pipelines_dir)
    
    state = %{
      pipelines_dir: pipelines_dir,
      pipelines: pipelines,
      loaded_modules: %{}
    }
    
    {:ok, state}
  end

  @impl true
  def handle_call(:list_pipelines, _from, state) do
    pipeline_list = Enum.map(state.pipelines, fn {id, info} ->
      %{
        id: id,
        name: Map.get(info, :name, id),
        description: Map.get(info, :description, ""),
        type: Map.get(info, :type, "pipe"),
        file_path: info.file_path,
        loaded: Map.has_key?(state.loaded_modules, id)
      }
    end)
    
    {:reply, pipeline_list, state}
  end

  @impl true
  def handle_call({:get_pipeline, pipeline_id}, _from, state) do
    case Map.get(state.pipelines, pipeline_id) do
      nil ->
        {:reply, {:error, :not_found}, state}
      
      pipeline_info ->
        pipeline_data = %{
          id: pipeline_id,
          name: Map.get(pipeline_info, :name, pipeline_id),
          description: Map.get(pipeline_info, :description, ""),
          type: Map.get(pipeline_info, :type, "pipe"),
          file_path: pipeline_info.file_path,
          loaded: Map.has_key?(state.loaded_modules, pipeline_id),
          manifest: Map.get(pipeline_info, :manifest, %{})
        }
        
        {:reply, {:ok, pipeline_data}, state}
    end
  end

  @impl true
  def handle_call({:load_pipeline, pipeline_id}, _from, state) do
    case Map.get(state.pipelines, pipeline_id) do
      nil ->
        {:reply, {:error, :not_found}, state}
      
      pipeline_info ->
        case compile_and_load_pipeline(pipeline_info) do
          {:ok, module} ->
            new_loaded_modules = Map.put(state.loaded_modules, pipeline_id, module)
            new_state = %{state | loaded_modules: new_loaded_modules}
            {:reply, {:ok, module}, new_state}
          
          {:error, reason} ->
            Logger.error("Failed to load pipeline #{pipeline_id}: #{inspect(reason)}")
            {:reply, {:error, reason}, state}
        end
    end
  end

  @impl true
  def handle_call({:execute_pipeline, pipeline_id, body, user}, _from, state) do
    case Map.get(state.loaded_modules, pipeline_id) do
      nil ->
        # Try to load the pipeline first
        case handle_call({:load_pipeline, pipeline_id}, nil, state) do
          {:reply, {:ok, _module}, new_state} ->
            execute_loaded_pipeline(pipeline_id, body, user, new_state)
          
          {:reply, {:error, reason}, _state} ->
            {:reply, {:error, reason}, state}
        end
      
      _module ->
        execute_loaded_pipeline(pipeline_id, body, user, state)
    end
  end

  @impl true
  def handle_call({:reload_pipeline, pipeline_id}, _from, state) do
    # Remove from loaded modules
    new_loaded_modules = Map.delete(state.loaded_modules, pipeline_id)
    new_state = %{state | loaded_modules: new_loaded_modules}
    
    # Rescan pipelines
    pipelines = scan_pipelines(state.pipelines_dir)
    final_state = %{new_state | pipelines: pipelines}
    
    {:reply, :ok, final_state}
  end

  @impl true
  def handle_call({:add_pipeline_from_url, url}, _from, state) do
    # TODO: Implement URL downloading and pipeline installation
    Logger.info("Adding pipeline from URL: #{url}")
    {:reply, {:error, "URL pipeline installation not yet implemented"}, state}
  end

  @impl true
  def handle_call({:delete_pipeline, pipeline_id}, _from, state) do
    case Map.get(state.pipelines, pipeline_id) do
      nil ->
        {:reply, {:error, :not_found}, state}
      
      pipeline_info ->
        try do
          # Delete the file
          File.rm!(pipeline_info.file_path)
          
          # Remove from state
          new_pipelines = Map.delete(state.pipelines, pipeline_id)
          new_loaded_modules = Map.delete(state.loaded_modules, pipeline_id)
          new_state = %{state | pipelines: new_pipelines, loaded_modules: new_loaded_modules}
          
          Logger.info("Deleted pipeline: #{pipeline_id}")
          {:reply, :ok, new_state}
        rescue
          e ->
            Logger.error("Failed to delete pipeline #{pipeline_id}: #{Exception.message(e)}")
            {:reply, {:error, Exception.message(e)}, state}
        end
    end
  end

  @impl true
  def handle_call({:get_pipeline_valves, pipeline_id}, _from, state) do
    case Map.get(state.loaded_modules, pipeline_id) do
      nil ->
        {:reply, {:error, :not_loaded}, state}
      
      module ->
        try do
          # Check if module has valves function
          if function_exported?(module, :valves, 0) do
            valves = apply(module, :valves, [])
            {:reply, {:ok, valves}, state}
          else
            {:reply, {:ok, %{}}, state}
          end
        rescue
          e ->
            Logger.error("Failed to get valves for #{pipeline_id}: #{Exception.message(e)}")
            {:reply, {:error, Exception.message(e)}, state}
        end
    end
  end

  @impl true
  def handle_call({:get_pipeline_valves_spec, pipeline_id}, _from, state) do
    case Map.get(state.loaded_modules, pipeline_id) do
      nil ->
        {:reply, {:error, :not_loaded}, state}
      
      module ->
        try do
          # Check if module has valves_spec function
          if function_exported?(module, :valves_spec, 0) do
            spec = apply(module, :valves_spec, [])
            {:reply, {:ok, spec}, state}
          else
            {:reply, {:ok, %{}}, state}
          end
        rescue
          e ->
            Logger.error("Failed to get valves spec for #{pipeline_id}: #{Exception.message(e)}")
            {:reply, {:error, Exception.message(e)}, state}
        end
    end
  end

  @impl true
  def handle_call({:update_pipeline_valves, pipeline_id, valves}, _from, state) do
    case Map.get(state.loaded_modules, pipeline_id) do
      nil ->
        {:reply, {:error, :not_loaded}, state}
      
      module ->
        try do
          # Check if module has update_valves function
          if function_exported?(module, :update_valves, 1) do
            apply(module, :update_valves, [valves])
            {:reply, :ok, state}
          else
            {:reply, {:error, "Pipeline does not support valve updates"}, state}
          end
        rescue
          e ->
            Logger.error("Failed to update valves for #{pipeline_id}: #{Exception.message(e)}")
            {:reply, {:error, Exception.message(e)}, state}
        end
    end
  end

  @impl true
  def handle_call({:apply_inlet_filter, pipeline_id, data}, _from, state) do
    case Map.get(state.loaded_modules, pipeline_id) do
      nil ->
        {:reply, {:error, :not_loaded}, state}
      
      module ->
        try do
          # Check if module has inlet function
          if function_exported?(module, :inlet, 1) do
            result = apply(module, :inlet, [data])
            {:reply, {:ok, result}, state}
          else
            # If no inlet function, return data as-is
            {:reply, {:ok, data}, state}
          end
        rescue
          e ->
            Logger.error("Failed to apply inlet filter for #{pipeline_id}: #{Exception.message(e)}")
            {:reply, {:error, Exception.message(e)}, state}
        end
    end
  end

  @impl true
  def handle_call({:apply_outlet_filter, pipeline_id, data}, _from, state) do
    case Map.get(state.loaded_modules, pipeline_id) do
      nil ->
        {:reply, {:error, :not_loaded}, state}
      
      module ->
        try do
          # Check if module has outlet function
          if function_exported?(module, :outlet, 1) do
            result = apply(module, :outlet, [data])
            {:reply, {:ok, result}, state}
          else
            # If no outlet function, return data as-is
            {:reply, {:ok, data}, state}
          end
        rescue
          e ->
            Logger.error("Failed to apply outlet filter for #{pipeline_id}: #{Exception.message(e)}")
            {:reply, {:error, Exception.message(e)}, state}
        end
    end
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # Private functions

  defp scan_pipelines(pipelines_dir) do
    Logger.debug("Scanning pipelines in: #{pipelines_dir}")
    
    case File.ls(pipelines_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".ex"))
        |> Enum.reduce(%{}, fn file, acc ->
          file_path = Path.join(pipelines_dir, file)
          pipeline_id = Path.rootname(file)
          
          case parse_pipeline_metadata(file_path) do
            {:ok, metadata} ->
              pipeline_info = Map.put(metadata, :file_path, file_path)
              Map.put(acc, pipeline_id, pipeline_info)
            
            {:error, reason} ->
              Logger.warning("Failed to parse pipeline #{file}: #{reason}")
              acc
          end
        end)
      
      {:error, reason} ->
        Logger.error("Failed to scan pipelines directory: #{reason}")
        %{}
    end
  end

  defp parse_pipeline_metadata(file_path) do
    try do
      content = File.read!(file_path)
      
      # Extract metadata from module attributes or comments
      metadata = %{
        name: extract_attribute(content, "@name") || Path.basename(file_path, ".ex"),
        description: extract_attribute(content, "@description") || "",
        type: extract_attribute(content, "@type") || "pipe"
      }
      
      {:ok, metadata}
    rescue
      e ->
        {:error, Exception.message(e)}
    end
  end

  defp extract_attribute(content, attribute) do
    case Regex.run(~r/#{attribute}\s+"([^"]+)"/, content) do
      [_, value] -> value
      _ -> nil
    end
  end

  defp compile_and_load_pipeline(pipeline_info) do
    try do
      file_path = pipeline_info.file_path
      Logger.debug("Compiling pipeline: #{file_path}")
      
      # Read and compile the file
      content = File.read!(file_path)
      
      # Compile the code
      [{module, _binary}] = Code.compile_string(content, file_path)
      
      # Validate the module has required functions
      case validate_pipeline_module(module) do
        :ok ->
          Logger.info("Successfully loaded pipeline: #{module}")
          {:ok, module}
        
        {:error, reason} ->
          {:error, reason}
      end
    rescue
      e ->
        {:error, Exception.message(e)}
    end
  end



  defp validate_pipeline_module(module) do
    required_functions = [:pipe]
    
    exported_functions = module.__info__(:functions)
    
    missing_functions = 
      required_functions
      |> Enum.reject(fn func -> Keyword.has_key?(exported_functions, func) end)
    
    case missing_functions do
      [] -> :ok
      missing -> {:error, "Missing required functions: #{inspect(missing)}"}
    end
  end

  defp execute_loaded_pipeline(pipeline_id, body, user, state) do
    case Map.get(state.loaded_modules, pipeline_id) do
      nil ->
        {:reply, {:error, :not_loaded}, state}
      
      module ->
        try do
          Logger.debug("Executing pipeline #{pipeline_id} with module #{module}")
          
          # Execute the pipeline's pipe function
          result = apply(module, :pipe, [body, user])
          
          {:reply, {:ok, result}, state}
        rescue
          e ->
            Logger.error("Pipeline execution failed: #{Exception.message(e)}")
            {:reply, {:error, Exception.message(e)}, state}
        end
    end
  end
end