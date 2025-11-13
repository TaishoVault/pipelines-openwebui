defmodule ElixirPipelines.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    api_key = Application.get_env(:elixir_pipelines, :api_key)

    case get_req_header(conn, "authorization") do
      ["Bearer " <> ^api_key] ->
        conn
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "Unauthorized"}))
        |> halt()
    end
  end
end
