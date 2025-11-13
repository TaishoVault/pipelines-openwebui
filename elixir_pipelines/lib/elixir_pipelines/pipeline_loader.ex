defmodule ElixirPipelines.PipelineLoader do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Logger.info("PipelineLoader starting, loading pipelines...")
    load_pipelines()
    {:ok, %{}}
  end

  def load_pipelines do
    pipelines_dir = Application.get_env(:elixir_pipelines, :pipelines_dir)
    Logger.info("Loading pipelines from #{pipelines_dir}")

    if File.exists?(pipelines_dir) do
      :ok = Agent.update(ElixirPipelines.PipelineRegistry, fn _ -> %{} end)
      pipelines_dir
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".ex"))
      |> Enum.each(&load_pipeline(&1, pipelines_dir))
    else
      Logger.warn("Pipelines directory not found at #{pipelines_dir}")
    end
  end

  defp load_pipeline(filename, dir) do
    path = Path.join(dir, filename)
    module_name_str = filename |> Path.basename(".ex") |> Macro.camelize()
    module_name = String.to_atom(module_name_str)

    Logger.info("Loading pipeline: #{module_name} from #{path}")

    try do
      case Code.compile_file(path) do
        [{loaded_module, _binary}] ->
          pipeline_dir = Path.join(dir, Atom.to_string(loaded_module) |> String.replace(".", "/"))
          File.mkdir_p(pipeline_dir)
          valves_path = Path.join(pipeline_dir, "valves.json")
          Logger.info("Looking for valves file at #{valves_path}")
          valves = if File.exists?(valves_path) do
            valves_path |> File.read!() |> Jason.decode!()
          else
            %{}
          end
          ElixirPipelines.PipelineRegistry.register_pipeline(loaded_module, valves)
          Logger.info("Successfully loaded and registered pipeline: #{loaded_module}")
        _ ->
          Logger.error("Failed to load pipeline: #{module_name}")
      end
    rescue
      e -> Logger.error("Failed to load pipeline: #{module_name} - #{inspect(e)}")
    end
  end
end
