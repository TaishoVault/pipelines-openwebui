# Pipeline Loader Documentation

**File**: `lib/pipelines_elixir/pipeline_loader.ex`

## Purpose

The `PipelinesElixir.PipelineLoader` module is the core component that provides Python-like dynamic import functionality for Elixir. It manages the complete lifecycle of pipeline modules, from loading and compilation to execution and cleanup.

## What This File Performs

### 1. Dynamic Module Loading
- **Runtime Compilation**: Compiles `.ex` files from the pipelines directory at runtime
- **Module Registration**: Registers compiled modules in the Erlang VM
- **Dependency Resolution**: Handles module dependencies and load order
- **Error Handling**: Provides comprehensive error handling for compilation failures

### 2. Pipeline Management
- **Lifecycle Management**: Manages loading, reloading, and unloading of pipeline modules
- **Metadata Tracking**: Maintains pipeline information, configuration, and state
- **Validation**: Ensures loaded modules conform to the expected pipeline interface
- **Caching**: Caches loaded modules for performance optimization

### 3. Hot Reloading
- **File Monitoring**: Tracks file modification timestamps for change detection
- **Automatic Reloading**: Automatically reloads changed pipeline files
- **State Preservation**: Maintains pipeline state across reloads when possible
- **Graceful Updates**: Handles updates without service interruption

### 4. API Compatibility
- **Python Equivalence**: Provides 1:1 API compatibility with Python pipelines server
- **Pipeline Operations**: Supports all pipeline CRUD operations
- **Valve Management**: Handles pipeline configuration and valve operations
- **Filter Processing**: Manages inlet and outlet filter operations

## Key Functions

### Public API Functions

#### `start_link/1`
Starts the GenServer with the specified pipelines directory.

#### `get_pipelines/0`
Returns a list of all loaded pipeline modules with their metadata.

#### `get_pipeline/1`
Retrieves a specific pipeline module by ID.

#### `load_pipeline/1`
Loads a pipeline from a file path with full validation.

#### `reload_pipeline/1`
Reloads an existing pipeline, preserving state when possible.

#### `add_pipeline_from_url/2`
Downloads and loads a pipeline from a remote URL.

#### `delete_pipeline/1`
Removes a pipeline from the system and cleans up resources.

#### `execute_pipeline/4`
Executes a pipeline with the provided parameters (body, user, model, extra).

#### Valve Management
- `get_pipeline_valves/1` - Retrieves pipeline configuration valves
- `get_pipeline_valves_spec/1` - Gets valve specification schema
- `update_pipeline_valves/2` - Updates pipeline configuration

#### Filter Operations
- `apply_inlet_filter/4` - Applies inlet filtering to requests
- `apply_outlet_filter/4` - Applies outlet filtering to responses

### GenServer Callbacks

#### `init/1`
Initializes the GenServer state and scans the pipelines directory for existing files.

#### `handle_call/3`
Handles synchronous requests for all pipeline operations.

#### `handle_cast/2`
Handles asynchronous operations like background reloading.

#### `handle_info/2`
Processes file system events and periodic maintenance tasks.

## State Management

The GenServer maintains the following state:

```elixir
%{
  pipelines_dir: String.t(),           # Directory path for pipeline files
  loaded_pipelines: %{},               # Map of loaded pipeline modules
  file_timestamps: %{},                # File modification tracking
  pipeline_metadata: %{}               # Pipeline configuration and info
}
```

## Pipeline Interface Requirements

Each pipeline module must implement:

### Required Functions
- `pipe/3` - Main processing function `(body, user, model) -> result`
- `info/0` - Returns pipeline metadata and configuration

### Optional Functions
- `inlet/3` - Request preprocessing `(body, user, model) -> modified_body`
- `outlet/3` - Response postprocessing `(body, user, model) -> modified_body`

### Example Pipeline Structure
```elixir
defmodule ExamplePipeline do
  def info do
    %{
      id: "example",
      name: "Example Pipeline",
      description: "A simple example pipeline",
      version: "1.0.0"
    }
  end

  def pipe(body, user, model) do
    # Process the request
    %{response: "Processed by example pipeline"}
  end
end
```

## Error Handling

The module provides comprehensive error handling for:
- **Compilation Errors**: Syntax errors, missing dependencies
- **Runtime Errors**: Execution failures, invalid responses
- **File System Errors**: Missing files, permission issues
- **Validation Errors**: Invalid pipeline interfaces, missing functions

## Performance Considerations

- **Module Caching**: Compiled modules are cached to avoid recompilation
- **Lazy Loading**: Modules are loaded on-demand to reduce startup time
- **Memory Management**: Automatic cleanup of unused modules
- **Concurrent Execution**: Supports concurrent pipeline execution

## Integration Points

- **File System**: Monitors and loads files from the pipelines directory
- **HTTP Router**: Provides pipeline execution services to the web layer
- **Logging System**: Comprehensive logging for debugging and monitoring
- **OTP Supervision**: Integrates with the application supervision tree

This module is the heart of the dynamic pipeline system, enabling the runtime flexibility that makes Pipelines Elixir equivalent to its Python counterpart.