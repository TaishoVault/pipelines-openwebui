defmodule ElixirPipelines.ChatController do
  require Logger
  import Plug.Conn

  def models(conn) do
    pipelines = ElixirPipelines.PipelineRegistry.all_pipelines()
    models = Enum.map(pipelines, fn {name, {_module, valves}} ->
      %{
        "id" => name,
        "name" => name,
        "object" => "model",
        "created" => :os.system_time(:seconds),
        "owned_by" => "openai",
        "pipeline" => %{
          "type" => "pipe",
          "valves" => valves != %{}
        }
      }
    end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{data: models, object: "list"}))
  end

  def chat_completions(conn) do
    Logger.info("Received chat completions request with body: #{inspect(conn.body_params)}")
    with %{"model" => model_name, "messages" => messages} <- conn.body_params do

      case ElixirPipelines.PipelineRegistry.get_pipeline(model_name) do
        {pipeline, valves} ->
          last_user_message = get_last_user_message(messages)
          response = pipeline.pipe(last_user_message, model_name, messages, conn.body_params, valves)
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Jason.encode!(%{choices: [%{message: %{content: response}}]}))
        nil ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(404, Jason.encode!(%{error: "Model not found"}))
      end
    else
      e ->
        Logger.error("Pattern match failed in chat_completions: #{inspect(e)}")
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{error: "Invalid request"}))
    end
  end

  defp get_last_user_message(messages) do
    messages
    |> Enum.reverse()
    |> Enum.find(&(&1["role"] == "user"))
    |> Map.get("content")
  end
end
