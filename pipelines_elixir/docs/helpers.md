# Helpers Documentation

**File**: `lib/pipelines_elixir/utils/helpers.ex`

## Purpose

The `PipelinesElixir.Utils.Helpers` module provides utility functions and helper methods used throughout the Pipelines Elixir application. These functions handle common operations like data validation, transformation, error handling, and system utilities.

## What This File Performs

### 1. Data Validation
- **Parameter Validation**: Validates function parameters and request data
- **Type Checking**: Ensures data types match expected formats
- **Schema Validation**: Validates data against predefined schemas
- **Constraint Checking**: Enforces business rules and constraints

### 2. Data Transformation
- **Format Conversion**: Converts data between different formats (JSON, maps, structs)
- **Data Normalization**: Normalizes data for consistent processing
- **Key Transformation**: Transforms map keys between different naming conventions
- **Value Sanitization**: Sanitizes input values for security and consistency

### 3. Error Handling
- **Error Formatting**: Formats errors for consistent API responses
- **Exception Wrapping**: Wraps exceptions with additional context
- **Error Classification**: Classifies errors by type and severity
- **Recovery Strategies**: Provides error recovery and fallback mechanisms

### 4. System Utilities
- **File Operations**: Common file system operations and utilities
- **Network Utilities**: Network-related helper functions
- **Time Utilities**: Time and date manipulation functions
- **Process Utilities**: Process and system information helpers

## Key Functions

### Data Validation Functions

#### `validate_required/2`
Validates that required fields are present in a map or struct.
```elixir
case Helpers.validate_required(params, [:pipeline_id, :body]) do
  :ok -> process_request(params)
  {:error, missing} -> {:error, "Missing required fields: #{inspect(missing)}"}
end
```

#### `validate_type/3`
Validates that a value matches the expected type.
```elixir
case Helpers.validate_type(value, :string, "pipeline_id") do
  :ok -> continue_processing()
  {:error, message} -> {:error, message}
end
```

#### `validate_pipeline_interface/1`
Validates that a module implements the required pipeline interface.
```elixir
case Helpers.validate_pipeline_interface(module) do
  :ok -> load_pipeline(module)
  {:error, missing_functions} -> {:error, "Invalid pipeline: #{inspect(missing_functions)}"}
end
```

### Data Transformation Functions

#### `normalize_params/1`
Normalizes request parameters to a consistent format.
```elixir
normalized_params = Helpers.normalize_params(raw_params)
```

#### `convert_keys/2`
Converts map keys between different naming conventions.
```elixir
# Convert snake_case to camelCase
camel_case_map = Helpers.convert_keys(snake_case_map, :camel_case)

# Convert camelCase to snake_case
snake_case_map = Helpers.convert_keys(camel_case_map, :snake_case)
```

#### `sanitize_input/1`
Sanitizes input data for security and consistency.
```elixir
safe_input = Helpers.sanitize_input(user_input)
```

#### `deep_merge/2`
Performs deep merging of nested maps and structures.
```elixir
merged_config = Helpers.deep_merge(default_config, user_config)
```

### Error Handling Functions

#### `format_error/1`
Formats errors into a consistent API response format.
```elixir
formatted_error = Helpers.format_error({:error, "Pipeline not found"})
# Returns: %{error: %{type: "not_found", message: "Pipeline not found"}}
```

#### `wrap_error/2`
Wraps an error with additional context information.
```elixir
contextual_error = Helpers.wrap_error(original_error, %{
  pipeline_id: "example",
  operation: "load_pipeline"
})
```

#### `classify_error/1`
Classifies errors by type for appropriate handling.
```elixir
case Helpers.classify_error(error) do
  :client_error -> send_400_response()
  :server_error -> send_500_response()
  :not_found -> send_404_response()
end
```

### System Utility Functions

#### `get_system_info/0`
Retrieves system information for monitoring and debugging.
```elixir
system_info = Helpers.get_system_info()
# Returns: %{memory: ..., processes: ..., uptime: ...}
```

#### `generate_id/0` and `generate_id/1`
Generates unique identifiers for requests, pipelines, etc.
```elixir
request_id = Helpers.generate_id()
pipeline_id = Helpers.generate_id("pipeline")
```

#### `safe_file_read/1`
Safely reads files with proper error handling.
```elixir
case Helpers.safe_file_read(file_path) do
  {:ok, content} -> process_content(content)
  {:error, reason} -> handle_file_error(reason)
end
```

#### `ensure_directory/1`
Ensures a directory exists, creating it if necessary.
```elixir
case Helpers.ensure_directory(pipelines_dir) do
  :ok -> continue_processing()
  {:error, reason} -> handle_directory_error(reason)
end
```

### Time and Date Utilities

#### `current_timestamp/0`
Returns the current timestamp in ISO 8601 format.
```elixir
timestamp = Helpers.current_timestamp()
# Returns: "2024-01-15T10:30:45.123Z"
```

#### `format_duration/1`
Formats duration in milliseconds to human-readable format.
```elixir
formatted = Helpers.format_duration(1500)
# Returns: "1.5s"
```

#### `parse_datetime/1`
Parses datetime strings in various formats.
```elixir
case Helpers.parse_datetime("2024-01-15T10:30:45Z") do
  {:ok, datetime} -> use_datetime(datetime)
  {:error, reason} -> handle_parse_error(reason)
end
```

### Network Utilities

#### `validate_url/1`
Validates URL format and accessibility.
```elixir
case Helpers.validate_url(pipeline_url) do
  :ok -> download_pipeline(pipeline_url)
  {:error, reason} -> handle_invalid_url(reason)
end
```

#### `download_file/2`
Downloads a file from a URL with proper error handling.
```elixir
case Helpers.download_file(url, local_path) do
  {:ok, file_path} -> process_downloaded_file(file_path)
  {:error, reason} -> handle_download_error(reason)
end
```

## Data Structures

### Error Response Format
```elixir
%{
  error: %{
    type: "error_type",           # Classification of the error
    message: "Human readable",    # User-friendly error message
    details: %{                   # Additional error context
      field: "specific_field",
      value: "invalid_value",
      constraint: "validation_rule"
    },
    code: "ERROR_CODE",          # Machine-readable error code
    timestamp: "2024-01-15T10:30:45.123Z"
  }
}
```

### System Information Format
```elixir
%{
  memory: %{
    total: 1024000000,           # Total memory in bytes
    used: 512000000,             # Used memory in bytes
    available: 512000000         # Available memory in bytes
  },
  processes: %{
    total: 150,                  # Total process count
    active: 75                   # Active process count
  },
  uptime: 3600000,              # Uptime in milliseconds
  version: "1.0.0",             # Application version
  elixir_version: "1.15.0",     # Elixir version
  otp_version: "26.0"           # OTP version
}
```

## Integration Points

### Application Integration
- **Configuration**: Reads application configuration for default values
- **Logging**: Integrates with the logging system for error reporting
- **Monitoring**: Provides metrics and health information
- **Error Handling**: Standardizes error handling across the application

### Pipeline Integration
- **Validation**: Validates pipeline modules and configurations
- **Data Processing**: Processes pipeline input and output data
- **Error Recovery**: Provides fallback mechanisms for pipeline failures
- **Performance Monitoring**: Tracks pipeline performance metrics

### HTTP Integration
- **Request Processing**: Processes HTTP request parameters
- **Response Formatting**: Formats HTTP responses consistently
- **Error Responses**: Generates appropriate HTTP error responses
- **Content Negotiation**: Handles content type negotiation

## Performance Considerations

### Efficiency
- **Lazy Evaluation**: Uses lazy evaluation for expensive operations
- **Caching**: Caches frequently computed values
- **Memory Management**: Efficient memory usage patterns
- **Concurrent Processing**: Supports concurrent operations where appropriate

### Scalability
- **Stateless Operations**: Most functions are stateless for scalability
- **Resource Management**: Proper resource cleanup and management
- **Error Isolation**: Isolates errors to prevent cascade failures
- **Performance Monitoring**: Built-in performance monitoring capabilities

## Security Considerations

### Input Validation
- **Sanitization**: Sanitizes all input data
- **Validation**: Comprehensive input validation
- **Type Safety**: Ensures type safety throughout processing
- **Injection Prevention**: Prevents various injection attacks

### Error Handling
- **Information Disclosure**: Prevents sensitive information disclosure in errors
- **Error Logging**: Logs security-relevant errors appropriately
- **Rate Limiting**: Supports rate limiting for security
- **Access Control**: Validates access permissions where applicable

This helpers module provides the foundational utilities that enable robust, secure, and efficient operation of the entire pipeline system while maintaining consistency with the Python pipelines approach.