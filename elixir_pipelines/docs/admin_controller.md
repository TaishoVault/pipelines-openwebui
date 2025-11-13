# AdminController Documentation

The `AdminController` is a controller that is responsible for handling the administrative endpoints for adding, deleting, and reloading pipelines.

## Usage

The `AdminController` provides the following functions:

- `add(conn)`: Adds a new pipeline from a URL.
- `delete(conn)`: Deletes a pipeline.
- `reload(conn)`: Reloads all pipelines.

The `AdminController` is protected by the `Auth` plug, which ensures that only authorized users can access the administrative endpoints.
