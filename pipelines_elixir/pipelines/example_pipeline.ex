defmodule Pipeline.ExamplePipeline do
  @moduledoc """
  Example pipeline demonstrating basic functionality.
  
  This pipeline shows how to:
  - Accept input data
  - Process the data
  - Return formatted results
  """

  @name "Example Pipeline"
  @description "A simple example pipeline for demonstration"
  @type "pipe"

  require Logger

  @doc """
  Main pipeline function that processes the input data.
  
  ## Parameters
  - body: The input data (map)
  - user: User information (map, optional)
  
  ## Returns
  - Processed result (map)
  """
  def pipe(body, user \\ nil) do
    Logger.info("Example pipeline executing with body: #{inspect(body)}")
    
    # Extract message from body
    message = Map.get(body, "message", "Hello, World!")
    
    # Process the message
    processed_message = String.upcase(message)
    
    # Create response
    response = %{
      original_message: message,
      processed_message: processed_message,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      user: user,
      pipeline: "example_pipeline"
    }
    
    Logger.info("Example pipeline completed successfully")
    response
  end
end