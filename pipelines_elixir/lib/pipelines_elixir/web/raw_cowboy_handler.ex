defmodule PipelinesElixir.Web.RawCowboyHandler do
  @moduledoc """
  Raw Cowboy handler for debugging HTTP connectivity issues.
  Bypasses Plug entirely to test basic HTTP functionality.
  """

  def init(req, state) do
    req = :cowboy_req.reply(200, 
      %{"content-type" => "text/plain"}, 
      "Raw Cowboy handler working!", 
      req)
    {:ok, req, state}
  end
end