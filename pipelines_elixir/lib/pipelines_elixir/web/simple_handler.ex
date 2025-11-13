defmodule PipelinesElixir.Web.SimpleHandler do
  @moduledoc """
  Simple Cowboy handler for testing HTTP connectivity.
  """

  def init(req, state) do
    response_body = Jason.encode!(%{
      status: "ok",
      message: "Simple handler working",
      method: :cowboy_req.method(req),
      path: :cowboy_req.path(req)
    })

    req = :cowboy_req.reply(200, 
      %{"content-type" => "application/json"}, 
      response_body, 
      req)

    {:ok, req, state}
  end
end