# Application Module Documentation

**File**: `lib/pipelines_elixir/application.ex`

## Purpose

The `PipelinesElixir.Application` module serves as the main entry point and supervisor for the entire Pipelines Elixir application. It is responsible for:

- Starting and supervising all core components
- Reading configuration from environment variables
- Setting up the supervision tree for fault tolerance
- Ensuring proper startup order of dependent services

## What This File Performs

### 1. Application Startup
- Reads configuration from environment variables (`PORT`, `HOST`, `PIPELINES_DIR`)
- Creates the pipelines directory if it doesn't exist
- Logs startup information for debugging and monitoring

### 2. Supervision Tree Management
- Starts the `PipelineLoader` GenServer for dynamic module management
- Starts the `CowboyServer` GenServer for HTTP request handling
- Uses a `one_for_one` supervision strategy for fault isolation

### 3. Configuration Management
- Provides runtime configuration reading (no recompilation needed)
- Sets sensible defaults for all configuration options
- Supports deployment-time configuration changes

## Key Functions

### `start/2`
The main application callback that:
- Reads environment configuration
- Creates necessary directories
- Defines the supervision tree
- Starts the supervisor with fault-tolerant strategy

### `parse_ip/1` (Private)
Utility function for parsing IP address strings into tuple format for network binding.

## Dependencies

This module depends on:
- `PipelinesElixir.PipelineLoader` - Must start first as other components depend on it
- `PipelinesElixir.Web.CowboyServer` - HTTP server component

## Configuration Options

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `PORT` | `"8000"` | HTTP server port |
| `HOST` | `"0.0.0.0"` | Server host binding |
| `PIPELINES_DIR` | `"./pipelines"` | Directory for pipeline modules |

## Supervision Strategy

Uses `one_for_one` supervision strategy, which means:
- If a child process crashes, only that child is restarted
- Other children continue running unaffected
- Provides fault isolation while maintaining service availability
- Automatic restart attempts with exponential backoff

## Integration Points

- **OTP Application Behavior**: Implements the standard Elixir application behavior
- **Environment Variables**: Reads configuration at runtime for deployment flexibility
- **File System**: Creates and manages the pipelines directory
- **Logging**: Provides startup and configuration logging for operations

This module is the foundation that enables the entire pipeline system to operate reliably in a fault-tolerant manner.