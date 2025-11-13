defmodule Pipeline.MathPipeline do
  @moduledoc """
  Mathematical operations pipeline.
  
  This pipeline demonstrates more complex data processing
  with mathematical operations and error handling.
  """

  @name "Math Pipeline"
  @description "Performs mathematical operations on input data"
  @type "pipe"

  require Logger

  @doc """
  Performs mathematical operations based on the input.
  
  Expected input format:
  %{
    "operation" => "add" | "subtract" | "multiply" | "divide",
    "a" => number,
    "b" => number
  }
  
  ## Parameters
  - body: The input data containing operation and operands
  - user: User information (map, optional)
  
  ## Returns
  - Mathematical result with metadata (map)
  """
  def pipe(body, user \\ nil) do
    Logger.info("Math pipeline executing with body: #{inspect(body)}")
    
    try do
      operation = Map.get(body, "operation")
      a = Map.get(body, "a")
      b = Map.get(body, "b")
      
      # Validate inputs
      unless operation && is_number(a) && is_number(b) do
        raise ArgumentError, "Invalid input: operation, a, and b are required and a, b must be numbers"
      end
      
      # Perform calculation
      result = case operation do
        "add" -> a + b
        "subtract" -> a - b
        "multiply" -> a * b
        "divide" -> 
          if b == 0 do
            raise ArithmeticError, "Division by zero"
          else
            a / b
          end
        _ -> 
          raise ArgumentError, "Unsupported operation: #{operation}"
      end
      
      # Return successful result
      %{
        operation: operation,
        operands: %{a: a, b: b},
        result: result,
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
        user: user,
        pipeline: "math_pipeline",
        status: "success"
      }
      
    rescue
      e ->
        Logger.error("Math pipeline error: #{Exception.message(e)}")
        
        %{
          error: Exception.message(e),
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
          user: user,
          pipeline: "math_pipeline",
          status: "error"
        }
    end
  end
end