# Elixir Pipelines Documentation

This document provides an overview of the Elixir Pipelines project, including its architecture, API, and usage.

## Architecture

The Elixir Pipelines project is a port of the Python `pipelines` project. It is a UI-agnostic OpenAI API plugin framework that allows you to create and run custom pipelines.

The project is built with Elixir and uses the following key technologies:

- **Plug.Cowboy:** A web server for handling HTTP requests.
- **Jason:** A JSON library for parsing and generating JSON.
- **Tesla:** An HTTP client for making HTTP requests.

The project is divided into the following main components:

- **PipelineLoader:** A `GenServer` that dynamically loads and compiles Elixir modules from the `pipelines` directory.
- **PipelineRegistry:** An `Agent` that stores and manages the loaded pipeline modules.
- **Router:** A `Plug.Router` that handles the API endpoints.
- **ChatController:** A controller that handles the `/chat/completions` and `/models` endpoints.
- **AdminController:** A controller that handles the administrative endpoints for adding, deleting, and reloading pipelines.

## API

The Elixir Pipelines project provides the following API endpoints:

- `GET /`: Returns the status of the server.
- `GET /v1`: Returns the status of the server.
- `GET /models`: Returns a list of the available pipelines.
- `GET /v1/models`: Returns a list of the available pipelines.
- `POST /chat/completions`: Executes a pipeline.
- `POST /v1/chat/completions`: Executes a pipeline.
- `POST /pipelines/add`: Adds a new pipeline from a URL.
- `DELETE /pipelines/delete`: Deletes a pipeline.
- `POST /pipelines/reload`: Reloads all pipelines.

## Usage

To use the Elixir Pipelines project, you will need to have Elixir and Erlang installed. You can then start the server by running the following command:

```
mix run --no-halt
```

The server will be started on port 9099. You can then send requests to the API endpoints to execute pipelines and manage the available pipelines.
