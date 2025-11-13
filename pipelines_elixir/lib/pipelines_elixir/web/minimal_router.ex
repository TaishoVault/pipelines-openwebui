defmodule PipelinesElixir.Web.MinimalRouter do
  @moduledoc """
  Minimal router for testing HTTP connectivity.
  """
  
  use Plug.Router
  
  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    IO.puts("Received GET / request")
    send_resp(conn, 200, "Hello World from Elixir Pipelines!")
  end

  match _ do
    IO.puts("Received unknown request: #{conn.method} #{conn.request_path}")
    send_resp(conn, 404, "Not found")
  end
end