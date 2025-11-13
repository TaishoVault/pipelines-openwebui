# Router Documentation

**File**: `lib/pipelines_elixir/web/router.ex`

## Purpose

The `PipelinesElixir.Web.Router` module implements the HTTP routing layer that provides 1:1 API compatibility with the Python pipelines server. It handles all incoming HTTP requests and translates them into appropriate pipeline operations.

## What This File Performs

### 1. HTTP Request Routing
- **Endpoint Mapping**: Maps HTTP requests to appropriate handler functions
- **Parameter Extraction**: Extracts path parameters, query strings, and request bodies
- **Content Negotiation**: Handles JSON request/response serialization
- **Error Handling**: Provides consistent error responses across all endpoints

### 2. API Compatibility
- **Python Equivalence**: Implements identical endpoints to the Python pipelines server
- **Request/Response Format**: Maintains exact request and response formats
- **Status Codes**: Uses identical HTTP status codes for all operations
- **Error Messages**: Provides compatible error message formats

### 3. Pipeline Integration
- **Pipeline Loader Interface**: Communicates with the PipelineLoader GenServer
- **Request Processing**: Handles pipeline execution requests
- **Configuration Management**: Manages pipeline valve and configuration operations
- **Filter Operations**: Processes inlet and outlet filter requests

## API Endpoints

### Health and Information
- `GET /` - Health check endpoint
- `GET /v1` - API version information

### Model Management
- `GET /models` - List available models (compatibility endpoint)
- `GET /v1/models` - List available models (versioned)

### Pipeline Management
- `GET /pipelines` - List all available pipelines
- `GET /v1/pipelines` - List all available pipelines (versioned)
- `POST /pipelines/add` - Add a new pipeline from URL
- `POST /v1/pipelines/add` - Add a new pipeline from URL (versioned)
- `POST /pipelines/upload` - Upload a pipeline file
- `POST /v1/pipelines/upload` - Upload a pipeline file (versioned)
- `DELETE /pipelines/delete` - Delete a pipeline
- `DELETE /v1/pipelines/delete` - Delete a pipeline (versioned)
- `POST /pipelines/reload` - Reload a pipeline
- `POST /v1/pipelines/reload` - Reload a pipeline (versioned)

### Pipeline Configuration (Valves)
- `GET /{pipeline_id}/valves` - Get pipeline valves
- `GET /v1/{pipeline_id}/valves` - Get pipeline valves (versioned)
- `GET /{pipeline_id}/valves/spec` - Get valve specifications
- `GET /v1/{pipeline_id}/valves/spec` - Get valve specifications (versioned)
- `POST /{pipeline_id}/valves/update` - Update pipeline valves
- `POST /v1/{pipeline_id}/valves/update` - Update pipeline valves (versioned)

### Pipeline Filters
- `POST /{pipeline_id}/filter/inlet` - Apply inlet filter
- `POST /v1/{pipeline_id}/filter/inlet` - Apply inlet filter (versioned)
- `POST /{pipeline_id}/filter/outlet` - Apply outlet filter
- `POST /v1/{pipeline_id}/filter/outlet` - Apply outlet filter (versioned)

### OpenAI Compatibility
- `POST /chat/completions` - OpenAI-compatible chat completions
- `POST /v1/chat/completions` - OpenAI-compatible chat completions (versioned)

## Request/Response Handling

### Request Processing
1. **Authentication**: Validates request authentication (if configured)
2. **Parameter Extraction**: Extracts and validates request parameters
3. **Content Parsing**: Parses JSON request bodies
4. **Validation**: Validates required parameters and formats
5. **Pipeline Delegation**: Delegates to appropriate PipelineLoader functions

### Response Generation
1. **Result Processing**: Processes pipeline execution results
2. **Error Handling**: Converts errors to appropriate HTTP responses
3. **JSON Serialization**: Serializes responses to JSON format
4. **Header Setting**: Sets appropriate HTTP headers and status codes
5. **Logging**: Logs request/response information for monitoring

## Error Handling

The router provides comprehensive error handling for:

### Client Errors (4xx)
- `400 Bad Request` - Invalid request parameters or format
- `404 Not Found` - Pipeline or resource not found
- `422 Unprocessable Entity` - Valid format but invalid content

### Server Errors (5xx)
- `500 Internal Server Error` - Pipeline execution errors
- `503 Service Unavailable` - System overload or maintenance

### Error Response Format
```json
{
  "error": {
    "type": "error_type",
    "message": "Human-readable error message",
    "details": {
      "additional": "context information"
    }
  }
}
```

## Middleware Stack

The router uses the following Plug middleware:

1. **Plug.Logger** - HTTP request logging
2. **Plug.Parsers** - JSON request body parsing
3. **Custom Authentication** - Request authentication (if enabled)
4. **Error Handling** - Consistent error response formatting

## Integration Points

### PipelineLoader Integration
- **Synchronous Calls**: Uses GenServer.call for immediate responses
- **Error Propagation**: Properly handles and converts PipelineLoader errors
- **State Management**: Maintains consistency with pipeline state

### Logging Integration
- **Request Logging**: Logs all incoming requests with timing information
- **Error Logging**: Detailed error logging for debugging
- **Performance Metrics**: Tracks response times and throughput

### Configuration Integration
- **Environment Variables**: Reads configuration from application environment
- **Runtime Configuration**: Supports runtime configuration changes
- **Feature Flags**: Supports enabling/disabling features via configuration

## Performance Considerations

- **Connection Pooling**: Efficient handling of concurrent connections
- **Request Parsing**: Optimized JSON parsing for large payloads
- **Response Streaming**: Supports streaming responses for large datasets
- **Caching**: Caches frequently accessed pipeline metadata

## Security Features

- **Input Validation**: Comprehensive validation of all input parameters
- **SQL Injection Prevention**: Safe parameter handling (though no SQL is used)
- **XSS Prevention**: Proper output encoding for web responses
- **Rate Limiting**: Configurable rate limiting for API endpoints (if enabled)

This router module serves as the primary interface between external clients and the pipeline system, ensuring complete API compatibility while providing robust error handling and performance optimization.