defmodule PipelinesElixir.Web.TestRouter do
  @moduledoc """
  Simple test router to debug HTTP issues.
  """
  
  use Plug.Router
  
  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  # Health check endpoint
  get "/" do
    response = %{
      status: "ok",
      message: "Test Router Working",
      version: "1.0.0"
    }
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(response))
  end

  # Catch all
  match _ do
    send_resp(conn, 404, "Not found")
  end
end