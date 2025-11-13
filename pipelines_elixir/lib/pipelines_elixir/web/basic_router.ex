defmodule PipelinesElixir.Web.BasicRouter do
  @moduledoc """
  Ultra-basic router for debugging HTTP connectivity issues.
  No middleware, no logging, just basic request handling.
  """
  
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Basic router working!")
  end
end