defmodule PipelinesElixir.Web.CowboyHandler do
  @moduledoc """
  Direct Cowboy handler for testing HTTP connectivity.
  """

  def init(req, state) do
    method = :cowboy_req.method(req)
    path = :cowboy_req.path(req)
    
    req2 = handle_request(method, path, req)
    {:ok, req2, state}
  end

  defp handle_request("GET", "/", req) do
    body = Jason.encode!(%{status: "ok", message: "Cowboy Handler Working"})
    
    :cowboy_req.reply(200, 
      %{"content-type" => "application/json"}, 
      body, 
      req)
  end

  defp handle_request(_, _, req) do
    :cowboy_req.reply(404, 
      %{"content-type" => "text/plain"}, 
      "Not Found", 
      req)
  end
end