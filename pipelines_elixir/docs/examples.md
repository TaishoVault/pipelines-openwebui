# Example Pipelines Documentation

**Files**: `pipelines/example_pipeline.ex`, `pipelines/echo_pipeline.ex`, `pipelines/math_pipeline.ex`

## Purpose

The example pipeline files demonstrate how to create pipeline modules that are compatible with the Pipelines Elixir system. They serve as templates and learning resources for developing custom pipelines.

## What These Files Perform

### 1. Pipeline Interface Implementation
- **Required Functions**: Implement the mandatory `pipe/3` and `info/0` functions
- **Optional Functions**: Demonstrate optional `inlet/3` and `outlet/3` functions
- **Interface Compliance**: Show how to comply with the pipeline interface requirements
- **Error Handling**: Demonstrate proper error handling within pipelines

### 2. Data Processing Examples
- **Input Processing**: Show how to process different types of input data
- **Output Generation**: Demonstrate various output formats and structures
- **Data Transformation**: Examples of data transformation and manipulation
- **Validation**: Input validation and sanitization examples

### 3. Configuration Management
- **Pipeline Metadata**: Show how to provide pipeline information and metadata
- **Valve Configuration**: Demonstrate configurable pipeline parameters (valves)
- **Default Values**: Examples of setting and using default configuration values
- **Dynamic Configuration**: Show how to handle runtime configuration changes

## Example Pipeline Files

### 1. Example Pipeline (`example_pipeline.ex`)

**Purpose**: Basic pipeline template showing minimal implementation.

```elixir
defmodule ExamplePipeline do
  @moduledoc """
  Example pipeline demonstrating basic pipeline interface implementation.
  
  This pipeline serves as a template for creating new pipelines and shows
  the minimal required implementation for a functional pipeline.
  """

  def info do
    %{
      id: "example",
      name: "Example Pipeline",
      description: "A simple example pipeline for demonstration purposes",
      version: "1.0.0",
      author: "Pipelines Elixir",
      license: "MIT",
      valves: %{
        enabled: %{
          type: "boolean",
          default: true,
          description: "Enable or disable the pipeline"
        },
        message_prefix: %{
          type: "string", 
          default: "[Example]",
          description: "Prefix to add to all messages"
        }
      }
    }
  end

  def pipe(body, user, model) do
    # Extract configuration from valves
    valves = Map.get(body, "valves", %{})
    enabled = Map.get(valves, "enabled", true)
    prefix = Map.get(valves, "message_prefix", "[Example]")
    
    if enabled do
      # Process the request
      messages = Map.get(body, "messages", [])
      
      # Add prefix to the last message
      updated_messages = case List.last(messages) do
        nil -> messages
        last_message ->
          updated_content = "#{prefix} #{Map.get(last_message, "content", "")}"
          updated_last = Map.put(last_message, "content", updated_content)
          List.replace_at(messages, -1, updated_last)
      end
      
      # Return updated body
      Map.put(body, "messages", updated_messages)
    else
      # Pipeline disabled, return unchanged
      body
    end
  end
end
```

### 2. Echo Pipeline (`echo_pipeline.ex`)

**Purpose**: Demonstrates input/output processing and filtering.

```elixir
defmodule EchoPipeline do
  @moduledoc """
  Echo pipeline that demonstrates inlet/outlet filtering and request processing.
  
  This pipeline echoes back the input with optional modifications and shows
  how to implement inlet and outlet filters for request/response processing.
  """

  def info do
    %{
      id: "echo",
      name: "Echo Pipeline", 
      description: "Echoes back the input with optional modifications",
      version: "1.0.0",
      valves: %{
        echo_format: %{
          type: "string",
          default: "Echo: {content}",
          description: "Format string for echo response"
        },
        add_timestamp: %{
          type: "boolean",
          default: false,
          description: "Add timestamp to echoed content"
        }
      }
    }
  end

  def inlet(body, user, model) do
    # Log incoming request
    IO.puts("Echo Pipeline - Incoming request from user: #{inspect(user)}")
    
    # Add request timestamp
    body
    |> Map.put("request_timestamp", DateTime.utc_now() |> DateTime.to_iso8601())
  end

  def pipe(body, user, model) do
    valves = Map.get(body, "valves", %{})
    echo_format = Map.get(valves, "echo_format", "Echo: {content}")
    add_timestamp = Map.get(valves, "add_timestamp", false)
    
    messages = Map.get(body, "messages", [])
    
    # Process each message
    echoed_messages = Enum.map(messages, fn message ->
      content = Map.get(message, "content", "")
      
      # Apply echo format
      echoed_content = String.replace(echo_format, "{content}", content)
      
      # Add timestamp if requested
      final_content = if add_timestamp do
        timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
        "#{echoed_content} [#{timestamp}]"
      else
        echoed_content
      end
      
      Map.put(message, "content", final_content)
    end)
    
    Map.put(body, "messages", echoed_messages)
  end

  def outlet(body, user, model) do
    # Log outgoing response
    IO.puts("Echo Pipeline - Sending response to user: #{inspect(user)}")
    
    # Add response timestamp
    body
    |> Map.put("response_timestamp", DateTime.utc_now() |> DateTime.to_iso8601())
  end
end
```

### 3. Math Pipeline (`math_pipeline.ex`)

**Purpose**: Demonstrates complex data processing and error handling.

```elixir
defmodule MathPipeline do
  @moduledoc """
  Math pipeline that performs mathematical operations on input data.
  
  This pipeline demonstrates complex data processing, error handling,
  and integration with external services or computations.
  """

  def info do
    %{
      id: "math",
      name: "Math Pipeline",
      description: "Performs mathematical operations and calculations",
      version: "1.0.0",
      valves: %{
        operation: %{
          type: "string",
          default: "calculate",
          description: "Type of mathematical operation to perform",
          enum: ["calculate", "solve", "evaluate"]
        },
        precision: %{
          type: "integer",
          default: 2,
          description: "Decimal precision for results"
        },
        max_complexity: %{
          type: "integer", 
          default: 100,
          description: "Maximum complexity level for operations"
        }
      }
    }
  end

  def pipe(body, user, model) do
    try do
      valves = Map.get(body, "valves", %{})
      operation = Map.get(valves, "operation", "calculate")
      precision = Map.get(valves, "precision", 2)
      
      messages = Map.get(body, "messages", [])
      
      # Process messages looking for mathematical expressions
      processed_messages = Enum.map(messages, fn message ->
        content = Map.get(message, "content", "")
        
        case extract_math_expressions(content) do
          [] -> 
            # No math expressions found
            message
          expressions ->
            # Process each mathematical expression
            results = Enum.map(expressions, fn expr ->
              case perform_calculation(expr, operation, precision) do
                {:ok, result} -> "#{expr} = #{result}"
                {:error, reason} -> "#{expr} = Error: #{reason}"
              end
            end)
            
            # Add results to the message
            updated_content = content <> "\n\nMath Results:\n" <> Enum.join(results, "\n")
            Map.put(message, "content", updated_content)
        end
      end)
      
      Map.put(body, "messages", processed_messages)
      
    rescue
      error ->
        # Handle pipeline errors gracefully
        error_message = %{
          "role" => "assistant",
          "content" => "Math Pipeline Error: #{Exception.message(error)}"
        }
        
        messages = Map.get(body, "messages", [])
        Map.put(body, "messages", messages ++ [error_message])
    end
  end

  # Private helper functions
  defp extract_math_expressions(content) do
    # Simple regex to find mathematical expressions
    # In a real implementation, this would be more sophisticated
    Regex.scan(~r/\d+\s*[\+\-\*\/]\s*\d+/, content)
    |> Enum.map(&List.first/1)
  end

  defp perform_calculation(expression, operation, precision) do
    try do
      # Simple expression evaluation
      # In a real implementation, use a proper math parser
      case Code.eval_string(expression) do
        {result, _} when is_number(result) ->
          formatted_result = Float.round(result * 1.0, precision)
          {:ok, formatted_result}
        _ ->
          {:error, "Invalid mathematical expression"}
      end
    rescue
      _ -> {:error, "Calculation failed"}
    end
  end
end
```

## Pipeline Interface Requirements

### Required Functions

#### `info/0`
Must return a map with pipeline metadata:
```elixir
%{
  id: "unique_pipeline_id",           # Unique identifier
  name: "Human Readable Name",        # Display name
  description: "Pipeline description", # Description
  version: "1.0.0",                   # Version string
  # Optional fields:
  author: "Author Name",              # Author information
  license: "MIT",                     # License
  valves: %{...}                      # Configuration schema
}
```

#### `pipe/3`
Main processing function that must accept:
- `body`: Request body (map)
- `user`: User information (map or nil)
- `model`: Model information (string or nil)

Must return the processed body (map).

### Optional Functions

#### `inlet/3`
Request preprocessing function with same signature as `pipe/3`.
Called before `pipe/3` to modify incoming requests.

#### `outlet/3`
Response postprocessing function with same signature as `pipe/3`.
Called after `pipe/3` to modify outgoing responses.

## Valve Configuration

Valves provide runtime configuration for pipelines:

```elixir
valves: %{
  parameter_name: %{
    type: "string|integer|boolean|float",  # Data type
    default: default_value,                # Default value
    description: "Parameter description",  # Human-readable description
    enum: ["option1", "option2"],         # Valid options (optional)
    min: 0,                               # Minimum value (optional)
    max: 100                              # Maximum value (optional)
  }
}
```

## Error Handling Best Practices

### 1. Graceful Degradation
```elixir
def pipe(body, user, model) do
  try do
    # Main processing logic
    process_request(body, user, model)
  rescue
    error ->
      # Log error and return safe fallback
      Logger.error("Pipeline error: #{Exception.message(error)}")
      add_error_message(body, "Processing failed, using fallback")
  end
end
```

### 2. Input Validation
```elixir
def pipe(body, user, model) do
  with {:ok, validated_body} <- validate_input(body),
       {:ok, result} <- process_validated_input(validated_body) do
    result
  else
    {:error, reason} -> add_error_message(body, reason)
  end
end
```

### 3. Resource Management
```elixir
def pipe(body, user, model) do
  # Ensure resources are cleaned up
  resource = acquire_resource()
  try do
    process_with_resource(body, resource)
  after
    release_resource(resource)
  end
end
```

## Testing Pipeline Examples

### Unit Testing
```elixir
defmodule ExamplePipelineTest do
  use ExUnit.Case
  
  test "basic pipeline functionality" do
    body = %{"messages" => [%{"content" => "Hello"}]}
    result = ExamplePipeline.pipe(body, nil, nil)
    
    assert %{"messages" => [%{"content" => "[Example] Hello"}]} = result
  end
end
```

### Integration Testing
```elixir
test "pipeline integration with loader" do
  {:ok, _pid} = PipelineLoader.start_link("./test/fixtures/pipelines")
  
  # Test pipeline loading
  assert {:ok, pipeline} = PipelineLoader.get_pipeline("example")
  
  # Test pipeline execution
  body = %{"messages" => [%{"content" => "Test"}]}
  result = PipelineLoader.execute_pipeline("example", body, nil, nil, %{})
  
  assert Map.has_key?(result, "messages")
end
```

These examples provide comprehensive templates for creating robust, feature-rich pipelines that integrate seamlessly with the Pipelines Elixir system while maintaining compatibility with the Python pipelines approach.