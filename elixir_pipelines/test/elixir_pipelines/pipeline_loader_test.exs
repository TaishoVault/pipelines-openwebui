defmodule ElixirPipelines.PipelineLoaderTest do
  use ExUnit.Case
  alias ElixirPipelines.PipelineLoader

  setup do
    on_exit(fn ->
      File.rm_rf!("test/fixtures/pipelines")
    end)
  end

  test "load_pipelines/0 loads and registers pipelines" do
    File.mkdir_p!("test/fixtures/pipelines")
    File.write!("test/fixtures/pipelines/test_pipeline.ex", """
    defmodule TestPipeline do
      def pipe(_user_message, _model_id, _messages, _body, _valves) do
        "hello from the test pipeline"
      end
    end
    """)

    Application.put_env(:elixir_pipelines, :pipelines_dir, "test/fixtures/pipelines")
    PipelineLoader.load_pipelines()

    assert {Elixir.TestPipeline, %{}} = ElixirPipelines.PipelineRegistry.get_pipeline("Elixir.TestPipeline")
  end
end
