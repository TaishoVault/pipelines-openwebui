defmodule PipelinesElixir.Utils.Helpers do
  @moduledoc """
  Common utility functions for Pipelines Elixir.
  
  This module provides helper functions that are commonly used
  across the application, similar to the utils in the Python version.
  
  Functions:
  - String manipulation
  - Data validation
  - Type conversion
  - Error handling
  - File operations
  """

  require Logger

  @doc """
  Safely converts a value to string, handling nil and complex types.
  """
  def safe_to_string(nil), do: ""
  def safe_to_string(value) when is_binary(value), do: value
  def safe_to_string(value) when is_atom(value), do: Atom.to_string(value)
  def safe_to_string(value) when is_number(value), do: to_string(value)
  def safe_to_string(value), do: inspect(value)

  @doc """
  Safely gets a value from a map with a default.
  """
  def safe_get(map, key, default \\ nil)
  def safe_get(map, key, default) when is_map(map) do
    Map.get(map, key, default)
  end
  def safe_get(_, _, default), do: default

  @doc """
  Validates that required keys exist in a map.
  """
  def validate_required_keys(map, required_keys) when is_map(map) and is_list(required_keys) do
    missing_keys = 
      required_keys
      |> Enum.reject(&Map.has_key?(map, &1))
    
    case missing_keys do
      [] -> :ok
      missing -> {:error, "Missing required keys: #{inspect(missing)}"}
    end
  end

  @doc """
  Sanitizes a string for safe use in file names or IDs.
  """
  def sanitize_string(str) when is_binary(str) do
    str
    |> String.replace(~r/[^a-zA-Z0-9_-]/, "_")
    |> String.replace(~r/_+/, "_")
    |> String.trim("_")
  end
  def sanitize_string(_), do: ""

  @doc """
  Converts string keys to atom keys in a map (recursively).
  """
  def atomize_keys(map) when is_map(map) do
    map
    |> Enum.map(fn
      {key, value} when is_binary(key) -> 
        {String.to_atom(key), atomize_keys(value)}
      {key, value} -> 
        {key, atomize_keys(value)}
    end)
    |> Map.new()
  end
  def atomize_keys(list) when is_list(list) do
    Enum.map(list, &atomize_keys/1)
  end
  def atomize_keys(value), do: value

  @doc """
  Converts atom keys to string keys in a map (recursively).
  """
  def stringify_keys(map) when is_map(map) do
    map
    |> Enum.map(fn
      {key, value} when is_atom(key) -> 
        {Atom.to_string(key), stringify_keys(value)}
      {key, value} -> 
        {key, stringify_keys(value)}
    end)
    |> Map.new()
  end
  def stringify_keys(list) when is_list(list) do
    Enum.map(list, &stringify_keys/1)
  end
  def stringify_keys(value), do: value

  @doc """
  Deep merges two maps, with the second map taking precedence.
  """
  def deep_merge(map1, map2) when is_map(map1) and is_map(map2) do
    Map.merge(map1, map2, fn _key, val1, val2 ->
      if is_map(val1) and is_map(val2) do
        deep_merge(val1, val2)
      else
        val2
      end
    end)
  end
  def deep_merge(_, map2), do: map2

  @doc """
  Safely parses a JSON string, returning an error tuple on failure.
  """
  def safe_json_decode(json_string) when is_binary(json_string) do
    case Jason.decode(json_string) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, "JSON decode error: #{inspect(reason)}"}
    end
  end
  def safe_json_decode(_), do: {:error, "Input is not a string"}

  @doc """
  Safely encodes data to JSON, returning an error tuple on failure.
  """
  def safe_json_encode(data) do
    case Jason.encode(data) do
      {:ok, json} -> {:ok, json}
      {:error, reason} -> {:error, "JSON encode error: #{inspect(reason)}"}
    end
  end

  @doc """
  Checks if a file exists and is readable.
  """
  def file_readable?(path) when is_binary(path) do
    case File.stat(path) do
      {:ok, %File.Stat{access: access}} -> 
        access in [:read, :read_write]
      {:error, _} -> 
        false
    end
  end
  def file_readable?(_), do: false

  @doc """
  Gets file modification time as a Unix timestamp.
  """
  def file_mtime(path) when is_binary(path) do
    case File.stat(path) do
      {:ok, %File.Stat{mtime: mtime}} -> 
        {:ok, :calendar.datetime_to_gregorian_seconds(mtime)}
      {:error, reason} -> 
        {:error, reason}
    end
  end

  @doc """
  Creates a directory if it doesn't exist.
  """
  def ensure_directory(path) when is_binary(path) do
    case File.mkdir_p(path) do
      :ok -> :ok
      {:error, reason} -> {:error, "Failed to create directory: #{reason}"}
    end
  end

  @doc """
  Measures execution time of a function.
  """
  def measure_time(fun) when is_function(fun, 0) do
    start_time = System.monotonic_time(:microsecond)
    result = fun.()
    end_time = System.monotonic_time(:microsecond)
    duration = end_time - start_time
    
    {result, duration}
  end

  @doc """
  Retries a function up to max_attempts times with exponential backoff.
  """
  def retry(fun, max_attempts \\ 3, base_delay \\ 100) when is_function(fun, 0) do
    retry_with_backoff(fun, max_attempts, base_delay, 1)
  end

  defp retry_with_backoff(fun, max_attempts, base_delay, attempt) do
    case fun.() do
      {:ok, result} -> 
        {:ok, result}
      
      {:error, reason} when attempt < max_attempts ->
        delay = base_delay * :math.pow(2, attempt - 1) |> round()
        Logger.debug("Retry attempt #{attempt} failed, retrying in #{delay}ms: #{inspect(reason)}")
        Process.sleep(delay)
        retry_with_backoff(fun, max_attempts, base_delay, attempt + 1)
      
      {:error, reason} ->
        Logger.error("All retry attempts failed: #{inspect(reason)}")
        {:error, reason}
      
      result ->
        {:ok, result}
    end
  end

  @doc """
  Truncates a string to a maximum length with ellipsis.
  """
  def truncate_string(str, max_length) when is_binary(str) and is_integer(max_length) do
    if String.length(str) <= max_length do
      str
    else
      String.slice(str, 0, max_length - 3) <> "..."
    end
  end

  @doc """
  Generates a random string of specified length.
  """
  def random_string(length \\ 8) when is_integer(length) and length > 0 do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> String.slice(0, length)
  end

  @doc """
  Checks if a value is blank (nil, empty string, or whitespace only).
  """
  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?(str) when is_binary(str), do: String.trim(str) == ""
  def blank?(_), do: false

  @doc """
  Returns the first non-blank value from a list of values.
  """
  def first_present([]), do: nil
  def first_present([head | tail]) do
    if blank?(head) do
      first_present(tail)
    else
      head
    end
  end
end