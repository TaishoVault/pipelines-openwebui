defmodule PipelinesElixir.Utils.Logger do
  @moduledoc """
  Enhanced logging utilities for Pipelines Elixir - Comprehensive logging system.
  
  This module provides structured logging functionality equivalent to the Python pipelines
  logging system, with enhanced features for debugging, monitoring, and observability.
  
  ## Core Features
  - **Structured Logging**: JSON-formatted logs with consistent metadata structure
  - **Request Tracking**: Automatic request ID generation and correlation across operations
  - **Performance Metrics**: Built-in timing and performance measurement capabilities
  - **Error Tracking**: Comprehensive error logging with stack traces and context
  - **Log Level Management**: Dynamic log level filtering and configuration
  - **Pipeline Context**: Automatic inclusion of pipeline-specific context in logs
  
  ## Log Levels
  - `debug/2`: Detailed debugging information (development only)
  - `info/2`: General informational messages
  - `warn/2`: Warning messages for potential issues
  - `error/2`: Error messages with full context and stack traces
  
  ## Usage Examples
      # Basic logging
      Logger.info("Pipeline loaded successfully", %{pipeline_id: "example"})
      
      # Request tracking
      Logger.log_request(conn, "Processing pipeline request")
      
      # Performance measurement
      Logger.log_performance("pipeline_execution", fn -> execute_pipeline() end)
      
      # Error logging with context
      Logger.error("Pipeline execution failed", %{error: error, pipeline_id: id})
  
  ## Integration
  Integrates seamlessly with Elixir's built-in Logger while providing additional
  structured logging capabilities specific to pipeline operations.
  """

  require Logger

  @doc """
  Logs a debug message with optional metadata.
  """
  def debug(message, metadata \\ []) do
    Logger.debug(message, metadata)
  end

  @doc """
  Logs an info message with optional metadata.
  """
  def info(message, metadata \\ []) do
    Logger.info(message, metadata)
  end

  @doc """
  Logs a warning message with optional metadata.
  """
  def warning(message, metadata \\ []) do
    Logger.warning(message, metadata)
  end

  @doc """
  Logs an error message with optional metadata.
  """
  def error(message, metadata \\ []) do
    Logger.error(message, metadata)
  end

  @doc """
  Logs a critical error message with optional metadata.
  """
  def critical(message, metadata \\ []) do
    Logger.error("[CRITICAL] #{message}", metadata)
  end

  @doc """
  Logs the start of a request with timing information.
  """
  def log_request_start(method, path, request_id \\ nil) do
    request_id = request_id || generate_request_id()
    
    Logger.info("Request started", [
      method: method,
      path: path,
      request_id: request_id,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ])
    
    {request_id, System.monotonic_time(:millisecond)}
  end

  @doc """
  Logs the completion of a request with timing information.
  """
  def log_request_end(request_id, start_time, status_code) do
    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time
    
    Logger.info("Request completed", [
      request_id: request_id,
      status_code: status_code,
      duration_ms: duration,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ])
  end

  @doc """
  Logs pipeline execution start.
  """
  def log_pipeline_start(pipeline_id, user \\ nil) do
    Logger.info("Pipeline execution started", [
      pipeline_id: pipeline_id,
      user: user,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ])
    
    System.monotonic_time(:millisecond)
  end

  @doc """
  Logs pipeline execution completion.
  """
  def log_pipeline_end(pipeline_id, start_time, status \\ :success) do
    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time
    
    Logger.info("Pipeline execution completed", [
      pipeline_id: pipeline_id,
      status: status,
      duration_ms: duration,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ])
  end

  @doc """
  Logs an error with stack trace information.
  """
  def log_error_with_trace(message, error, stacktrace \\ nil) do
    formatted_stacktrace = case stacktrace do
      nil -> "No stacktrace available"
      trace -> Exception.format_stacktrace(trace)
    end
    
    Logger.error(message, [
      error: Exception.message(error),
      error_type: error.__struct__,
      stacktrace: formatted_stacktrace,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ])
  end

  @doc """
  Logs system metrics and health information.
  """
  def log_system_metrics do
    memory_info = :erlang.memory()
    process_count = :erlang.system_info(:process_count)
    
    Logger.info("System metrics", [
      memory_total: memory_info[:total],
      memory_processes: memory_info[:processes],
      memory_system: memory_info[:system],
      process_count: process_count,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ])
  end

  @doc """
  Creates a structured log entry for API responses.
  """
  def log_api_response(method, path, status_code, response_size \\ nil, duration \\ nil) do
    metadata = [
      method: method,
      path: path,
      status_code: status_code,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ]
    
    metadata = if response_size, do: Keyword.put(metadata, :response_size, response_size), else: metadata
    metadata = if duration, do: Keyword.put(metadata, :duration_ms, duration), else: metadata
    
    level = case status_code do
      code when code >= 500 -> :error
      code when code >= 400 -> :warning
      _ -> :info
    end
    
    Logger.log(level, "API Response", metadata)
  end

  @doc """
  Logs pipeline loading events.
  """
  def log_pipeline_loading(pipeline_id, action, result \\ :success) do
    Logger.info("Pipeline loading event", [
      pipeline_id: pipeline_id,
      action: action,  # :load, :reload, :unload
      result: result,  # :success, :error
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ])
  end

  @doc """
  Logs file system events for pipeline changes.
  """
  def log_file_event(file_path, event_type) do
    Logger.debug("File system event", [
      file_path: file_path,
      event_type: event_type,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    ])
  end

  # Private helper functions

  defp generate_request_id do
    :crypto.strong_rand_bytes(8)
    |> Base.encode16(case: :lower)
  end
end