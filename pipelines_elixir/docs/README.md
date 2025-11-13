# Pipelines Elixir Documentation

This directory contains comprehensive documentation for the Pipelines Elixir project - a 1:1 port of the Python open-webui/pipelines server to Elixir.

## Overview

Pipelines Elixir provides a complete implementation of the Python pipelines server with the following key features:

- **Dynamic Module Loading**: Runtime compilation and loading of Elixir pipeline modules
- **1:1 API Compatibility**: Complete compatibility with the Python pipelines REST API
- **Comprehensive Logging**: Enhanced logging system with structured output and request tracking
- **Fault Tolerance**: Robust supervision tree with automatic restart capabilities
- **Hot Reloading**: Automatic detection and reloading of changed pipeline files

## Architecture

The application follows a standard Elixir/OTP architecture with the following components:

```
PipelinesElixir.Application (Supervisor)
├── PipelinesElixir.PipelineLoader (GenServer)
└── PipelinesElixir.Web.CowboyServer (GenServer)
    └── HTTP Router with API endpoints
```

## Documentation Files

- [`application.md`](./application.md) - Main application module and supervision tree
- [`pipeline_loader.md`](./pipeline_loader.md) - Dynamic module loading and pipeline management
- [`router.md`](./router.md) - HTTP routing and API endpoint handling
- [`cowboy_server.md`](./cowboy_server.md) - HTTP server implementation
- [`logger.md`](./logger.md) - Enhanced logging utilities
- [`helpers.md`](./helpers.md) - Utility functions and helpers
- [`examples.md`](./examples.md) - Example pipeline implementations
- [`api_compatibility.md`](./api_compatibility.md) - API compatibility documentation

## Quick Start

1. Install dependencies: `mix deps.get`
2. Start the server: `mix run --no-halt`
3. The server will start on port 8000 by default

## Configuration

The application is configured via environment variables:

- `PORT`: HTTP server port (default: 8000)
- `HOST`: Server host binding (default: "0.0.0.0")
- `PIPELINES_DIR`: Directory containing pipeline modules (default: "./pipelines")

## Pipeline Development

See [`examples.md`](./examples.md) for detailed information on creating pipeline modules.