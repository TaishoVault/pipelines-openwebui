# Router Documentation

The `Router` is a `Plug.Router` that is responsible for handling the API endpoints.

## Usage

The `Router` is started as part of the application's supervision tree. It defines the following routes:

- `GET /`: Returns the status of the server.
- `GET /v1`: Returns the status of the server.
- `GET /models`: Returns a list of the available pipelines.
- `GET /v1/models`: Returns a list of the available pipelines.
- `POST /chat/completions`: Executes a pipeline.
- `POST /v1/chat/completions`: Executes a pipeline.
- `forward "/pipelines"`: Forwards requests to the `AdminRouter`.
- `forward "/v1/pipelines"`: Forwards requests to the `AdminRouter`.
