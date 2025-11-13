defmodule ElixirPipelines.RequestId do
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    request_id = System.system_time(:nanosecond) |> Integer.to_string()
    Logger.metadata(request_id: request_id)
    put_req_header(conn, "x-request-id", request_id)
  end
end
