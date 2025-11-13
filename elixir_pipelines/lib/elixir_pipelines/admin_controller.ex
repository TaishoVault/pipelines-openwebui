defmodule ElixirPipelines.AdminController do
  require Logger
  import Plug.Conn

  def add(conn) do
    with %{"url" => url} <- conn.body_params do
      pipelines_dir = Application.get_env(:elixir_pipelines, :pipelines_dir)
      filename = Path.basename(url)
      filepath = Path.join(pipelines_dir, filename)

      case :httpc.request(:get, {to_charlist(url), []}, [], [body: :binary]) do
        {:ok, {{_version, 200, 'OK'}, _headers, body}} ->
          File.write!(filepath, body)
          module_name_str = filename |> Path.basename(".ex") |> Macro.camelize()
          pipeline_dir = Path.join(pipelines_dir, "Elixir.#{module_name_str}" |> String.replace(".", "/"))
          File.mkdir_p(pipeline_dir)
          ElixirPipelines.PipelineLoader.load_pipelines()
          send_resp(conn, 200, Jason.encode!(%{status: "ok"}))
        {:error, reason} ->
          Logger.error("Failed to download pipeline: #{inspect(reason)}")
          send_resp(conn, 500, Jason.encode!(%{error: "Failed to download pipeline"}))
      end
    else
      _ ->
        send_resp(conn, 400, Jason.encode!(%{error: "Invalid request"}))
    end
  end

  def delete(conn) do
    with %{"id" => id} <- conn.body_params do
      pipelines_dir = Application.get_env(:elixir_pipelines, :pipelines_dir)
      filename = "#{id}.ex"
      filepath = Path.join(pipelines_dir, filename)

      if File.exists?(filepath) do
        File.rm!(filepath)
        pipeline_dir = Path.join(pipelines_dir, "Elixir.#{id}" |> String.replace(".", "/"))
        File.rm_rf!(pipeline_dir)
        ElixirPipelines.PipelineLoader.load_pipelines()
        send_resp(conn, 200, Jason.encode!(%{status: "ok"}))
      else
        send_resp(conn, 404, Jason.encode!(%{error: "Pipeline not found"}))
      end
    else
      _ ->
        send_resp(conn, 400, Jason.encode!(%{error: "Invalid request"}))
    end
  end

  def reload(conn) do
    ElixirPipelines.PipelineLoader.load_pipelines()
    send_resp(conn, 200, Jason.encode!(%{status: "ok"}))
  end
end
