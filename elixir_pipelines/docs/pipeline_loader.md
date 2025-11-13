# PipelineLoader Documentation

The `PipelineLoader` is a `GenServer` that is responsible for dynamically loading and compiling Elixir modules from the `pipelines` directory.

## Usage

The `PipelineLoader` is started as part of the application's supervision tree. When it starts, it reads the `pipelines` directory and compiles any Elixir source files that it finds. The compiled modules are then registered with the `PipelineRegistry`.

The `PipelineLoader` also provides a `load_pipelines/0` function that can be used to reload all pipelines. This function is used by the `AdminController` to reload the pipelines when a new pipeline is added or a pipeline is deleted.
