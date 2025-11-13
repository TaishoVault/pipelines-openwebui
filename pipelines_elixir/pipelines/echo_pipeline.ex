defmodule Pipeline.EchoPipeline do
  @moduledoc """
  Echo pipeline that returns the input data unchanged.
  
  This pipeline is useful for testing and debugging.
  """

  @name "Echo Pipeline"
  @description "Returns the input data unchanged"
  @type "pipe"

  require Logger

  @doc """
  Echo function that returns the input data with metadata.
  
  ## Parameters
  - body: The input data (any type)
  - user: User information (map, optional)
  
  ## Returns
  - Echo response with metadata (map)
  """
  def pipe(body, user \\ nil) do
    Logger.info("Echo pipeline executing")
    
    %{
      echo: body,
      user: user,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      pipeline: "echo_pipeline",
      message: "This is an echo of your input"
    }
  end
end