defmodule PipelinesElixir.Web.CowboyServer do
  @moduledoc """
  GenServer that starts and manages a raw Cowboy HTTP server.
  This bypasses Plug entirely to test basic HTTP functionality.
  """
  
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    port = Keyword.get(opts, :port, 9090)
    
    dispatch = :cowboy_router.compile([
      {:_, [
        {"/", PipelinesElixir.Web.RawCowboyHandler, []}
      ]}
    ])
    
    case :cowboy.start_clear(:http, [port: port, ip: {0, 0, 0, 0}], %{env: %{dispatch: dispatch}}) do
      {:ok, _pid} ->
        Logger.info("Raw Cowboy server started on localhost:#{port}")
        {:ok, %{port: port}}
      {:error, reason} ->
        Logger.error("Failed to start Cowboy server: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  def terminate(_reason, %{port: port}) do
    :cowboy.stop_listener(:http)
    Logger.info("Cowboy server stopped on port #{port}")
    :ok
  end
end