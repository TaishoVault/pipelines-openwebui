defmodule ElixirPipelines.PipelineRegistry do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def register_pipeline(module, valves \\ %{}) do
    Agent.update(__MODULE__, &Map.put(&1, Atom.to_string(module), {module, valves}))
  end

  def get_pipeline(name) do
    Agent.get(__MODULE__, &Map.get(&1, name))
  end

  def all_pipelines do
    Agent.get(__MODULE__, & &1)
  end
end
