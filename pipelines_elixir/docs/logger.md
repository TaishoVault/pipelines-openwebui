# Logger Utilities Documentation

**File**: `lib/pipelines_elixir/utils/logger.ex`

## Purpose

The `PipelinesElixir.Utils.Logger` module provides enhanced logging capabilities that extend Elixir's built-in Logger with structured logging, request tracking, and performance monitoring features equivalent to the Python pipelines logging system.

## What This File Performs

### 1. Structured Logging
- **JSON Formatting**: Provides JSON-formatted log output for machine parsing
- **Metadata Enrichment**: Automatically adds contextual metadata to log entries
- **Consistent Structure**: Ensures consistent log entry structure across the application
- **Field Standardization**: Standardizes common fields like timestamps, levels, and sources

### 2. Request Tracking
- **Request ID Generation**: Generates unique request IDs for correlation
- **Request Lifecycle Tracking**: Tracks requests from start to completion
- **Cross-Component Correlation**: Correlates log entries across different components
- **Request Context Preservation**: Maintains request context throughout processing

### 3. Performance Monitoring
- **Execution Timing**: Measures and logs execution times for operations
- **Performance Metrics**: Collects performance metrics for monitoring
- **Bottleneck Identification**: Helps identify performance bottlenecks
- **Resource Usage Tracking**: Tracks memory and CPU usage patterns

### 4. Error Tracking
- **Stack Trace Capture**: Captures and formats stack traces for errors
- **Error Context**: Provides rich context information for debugging
- **Error Categorization**: Categorizes errors by type and severity
- **Error Aggregation**: Supports error aggregation and reporting

## Key Functions

### Basic Logging Functions

#### `debug/2`
Logs debug-level messages with optional metadata.
```elixir
Logger.debug("Pipeline compilation started", %{pipeline_id: "example"})
```

#### `info/2`
Logs informational messages with structured metadata.
```elixir
Logger.info("Pipeline loaded successfully", %{
  pipeline_id: "example",
  load_time_ms: 150,
  file_size: 2048
})
```

#### `warn/2`
Logs warning messages for potential issues.
```elixir
Logger.warn("Pipeline deprecated function used", %{
  pipeline_id: "example",
  function: "old_pipe/2",
  replacement: "pipe/3"
})
```

#### `error/2`
Logs error messages with full context and stack traces.
```elixir
Logger.error("Pipeline execution failed", %{
  pipeline_id: "example",
  error: inspect(error),
  stacktrace: Exception.format_stacktrace(__STACKTRACE__)
})
```

### Request Tracking Functions

#### `log_request/2`
Logs HTTP request information with automatic request ID generation.
```elixir
Logger.log_request(conn, "Processing pipeline request")
```

#### `log_response/3`
Logs HTTP response information with timing and status.
```elixir
Logger.log_response(conn, status, duration_ms)
```

#### `with_request_id/2`
Executes a function with request ID context.
```elixir
Logger.with_request_id(request_id, fn ->
  # Operations here will include the request ID in logs
end)
```

### Performance Monitoring Functions

#### `log_performance/2`
Measures and logs the execution time of a function.
```elixir
result = Logger.log_performance("pipeline_execution", fn ->
  execute_pipeline(pipeline_id, params)
end)
```

#### `log_timing/3`
Logs timing information for specific operations.
```elixir
Logger.log_timing("database_query", start_time, end_time)
```

#### `log_metrics/2`
Logs performance metrics and system statistics.
```elixir
Logger.log_metrics("system_stats", %{
  memory_usage: :erlang.memory(:total),
  process_count: :erlang.system_info(:process_count)
})
```

### Error Handling Functions

#### `log_error/3`
Logs errors with full context and optional stack traces.
```elixir
Logger.log_error("Pipeline compilation failed", error, %{
  pipeline_id: "example",
  file_path: "/path/to/pipeline.ex"
})
```

#### `log_exception/2`
Logs exceptions with automatic stack trace capture.
```elixir
try do
  risky_operation()
rescue
  e -> Logger.log_exception(e, %{context: "additional info"})
end
```

## Log Structure

### Standard Log Entry Format
```json
{
  "timestamp": "2024-01-15T10:30:45.123Z",
  "level": "info",
  "message": "Pipeline loaded successfully",
  "metadata": {
    "pipeline_id": "example",
    "load_time_ms": 150,
    "request_id": "req_abc123",
    "component": "pipeline_loader",
    "pid": "#PID<0.123.0>"
  }
}
```

### Request Log Entry Format
```json
{
  "timestamp": "2024-01-15T10:30:45.123Z",
  "level": "info",
  "message": "HTTP request processed",
  "metadata": {
    "request_id": "req_abc123",
    "method": "POST",
    "path": "/v1/pipelines/example/pipe",
    "status": 200,
    "duration_ms": 45,
    "user_agent": "curl/7.68.0",
    "remote_ip": "192.168.1.100"
  }
}
```

### Error Log Entry Format
```json
{
  "timestamp": "2024-01-15T10:30:45.123Z",
  "level": "error",
  "message": "Pipeline execution failed",
  "metadata": {
    "pipeline_id": "example",
    "error_type": "RuntimeError",
    "error_message": "Division by zero",
    "stacktrace": ["...", "..."],
    "request_id": "req_abc123",
    "context": {
      "user": "user123",
      "model": "gpt-3.5-turbo"
    }
  }
}
```

## Configuration

### Log Levels
The module supports standard Elixir log levels:
- `:debug` - Detailed debugging information
- `:info` - General informational messages
- `:warn` - Warning messages for potential issues
- `:error` - Error messages requiring attention

### Metadata Configuration
Configurable metadata fields:
- **Request ID**: Unique identifier for request correlation
- **Component**: Source component generating the log
- **Pipeline ID**: Identifier for the pipeline being processed
- **User Context**: User information for audit trails
- **Performance Metrics**: Timing and resource usage information

## Integration Points

### Elixir Logger Integration
- **Backend Compatibility**: Works with all Elixir Logger backends
- **Configuration Inheritance**: Inherits Logger configuration settings
- **Level Filtering**: Respects Logger level filtering configuration
- **Format Compatibility**: Compatible with existing Logger formatters

### Application Integration
- **Request Context**: Integrates with HTTP request processing
- **Pipeline Context**: Provides pipeline-specific logging context
- **Error Handling**: Integrates with application error handling
- **Monitoring Systems**: Compatible with external monitoring systems

### External Systems
- **Log Aggregation**: Compatible with log aggregation systems (ELK, Splunk)
- **Monitoring Tools**: Integrates with monitoring tools (Prometheus, Grafana)
- **Alerting Systems**: Supports alerting based on log patterns
- **Audit Systems**: Provides audit trail capabilities

## Performance Considerations

### Logging Overhead
- **Lazy Evaluation**: Uses lazy evaluation for expensive log operations
- **Level Checking**: Checks log levels before expensive operations
- **Metadata Caching**: Caches frequently used metadata
- **Async Logging**: Supports asynchronous logging for performance

### Memory Management
- **Buffer Management**: Manages log buffers to prevent memory leaks
- **Metadata Cleanup**: Automatically cleans up request-specific metadata
- **String Optimization**: Optimizes string operations for log messages
- **GC Friendly**: Designed to be garbage collector friendly

This logging module provides comprehensive observability into the pipeline system, enabling effective debugging, monitoring, and performance optimization while maintaining compatibility with the Python pipelines logging approach.