# PipelineRegistry Documentation

The `PipelineRegistry` is an `Agent` that is responsible for storing and managing the loaded pipeline modules.

## Usage

The `PipelineRegistry` is started as part of the application's supervision tree. It provides the following functions:

- `register_pipeline(module, valves)`: Registers a pipeline module and its valves with the registry.
- `get_pipeline(name)`: Returns a pipeline module and its valves from the registry.
- `all_pipelines()`: Returns all pipeline modules and their valves from the registry.
