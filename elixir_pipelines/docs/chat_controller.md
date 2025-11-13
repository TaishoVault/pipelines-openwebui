# ChatController Documentation

The `ChatController` is a controller that is responsible for handling the `/chat/completions` and `/models` endpoints.

## Usage

The `ChatController` provides the following functions:

- `models(conn)`: Returns a list of the available pipelines.
- `chat_completions(conn)`: Executes a pipeline.

The `chat_completions` function gets the pipeline from the `PipelineRegistry` and executes its `pipe` function. It then returns the response from the pipeline to the client.
