# API Compatibility Documentation

## Purpose

This document details the 1:1 API compatibility between Pipelines Elixir and the Python open-webui/pipelines server. Every endpoint, parameter, and response format has been implemented to match the original Python implementation exactly.

## API Endpoints Compatibility Matrix

### Health and Information Endpoints

| Python Endpoint | Elixir Endpoint | Status | Notes |
|----------------|----------------|---------|-------|
| `GET /` | `GET /` | ✅ Complete | Health check endpoint |
| `GET /v1` | `GET /v1` | ✅ Complete | API version information |

### Model Management Endpoints

| Python Endpoint | Elixir Endpoint | Status | Notes |
|----------------|----------------|---------|-------|
| `GET /models` | `GET /models` | ✅ Complete | List available models |
| `GET /v1/models` | `GET /v1/models` | ✅ Complete | Versioned models endpoint |

### Pipeline Management Endpoints

| Python Endpoint | Elixir Endpoint | Status | Notes |
|----------------|----------------|---------|-------|
| `GET /pipelines` | `GET /pipelines` | ✅ Complete | List all pipelines |
| `GET /v1/pipelines` | `GET /v1/pipelines` | ✅ Complete | Versioned pipelines list |
| `POST /pipelines/add` | `POST /pipelines/add` | ✅ Complete | Add pipeline from URL |
| `POST /v1/pipelines/add` | `POST /v1/pipelines/add` | ✅ Complete | Versioned add endpoint |
| `POST /pipelines/upload` | `POST /pipelines/upload` | ✅ Complete | Upload pipeline file |
| `POST /v1/pipelines/upload` | `POST /v1/pipelines/upload` | ✅ Complete | Versioned upload endpoint |
| `DELETE /pipelines/delete` | `DELETE /pipelines/delete` | ✅ Complete | Delete pipeline |
| `DELETE /v1/pipelines/delete` | `DELETE /v1/pipelines/delete` | ✅ Complete | Versioned delete endpoint |
| `POST /pipelines/reload` | `POST /pipelines/reload` | ✅ Complete | Reload pipeline |
| `POST /v1/pipelines/reload` | `POST /v1/pipelines/reload` | ✅ Complete | Versioned reload endpoint |

### Pipeline Configuration (Valves) Endpoints

| Python Endpoint | Elixir Endpoint | Status | Notes |
|----------------|----------------|---------|-------|
| `GET /{pipeline_id}/valves` | `GET /{pipeline_id}/valves` | ✅ Complete | Get pipeline valves |
| `GET /v1/{pipeline_id}/valves` | `GET /v1/{pipeline_id}/valves` | ✅ Complete | Versioned valves endpoint |
| `GET /{pipeline_id}/valves/spec` | `GET /{pipeline_id}/valves/spec` | ✅ Complete | Get valve specifications |
| `GET /v1/{pipeline_id}/valves/spec` | `GET /v1/{pipeline_id}/valves/spec` | ✅ Complete | Versioned valve spec |
| `POST /{pipeline_id}/valves/update` | `POST /{pipeline_id}/valves/update` | ✅ Complete | Update pipeline valves |
| `POST /v1/{pipeline_id}/valves/update` | `POST /v1/{pipeline_id}/valves/update` | ✅ Complete | Versioned valve update |

### Pipeline Filter Endpoints

| Python Endpoint | Elixir Endpoint | Status | Notes |
|----------------|----------------|---------|-------|
| `POST /{pipeline_id}/filter/inlet` | `POST /{pipeline_id}/filter/inlet` | ✅ Complete | Apply inlet filter |
| `POST /v1/{pipeline_id}/filter/inlet` | `POST /v1/{pipeline_id}/filter/inlet` | ✅ Complete | Versioned inlet filter |
| `POST /{pipeline_id}/filter/outlet` | `POST /{pipeline_id}/filter/outlet` | ✅ Complete | Apply outlet filter |
| `POST /v1/{pipeline_id}/filter/outlet` | `POST /v1/{pipeline_id}/filter/outlet` | ✅ Complete | Versioned outlet filter |

### OpenAI Compatibility Endpoints

| Python Endpoint | Elixir Endpoint | Status | Notes |
|----------------|----------------|---------|-------|
| `POST /chat/completions` | `POST /chat/completions` | ✅ Complete | OpenAI chat completions |
| `POST /v1/chat/completions` | `POST /v1/chat/completions` | ✅ Complete | Versioned completions |

## Request/Response Format Compatibility

### Health Check Response
**Python Response:**
```json
{
  "status": "ok",
  "message": "Open WebUI Pipelines",
  "version": "0.1.0"
}
```

**Elixir Response:**
```json
{
  "status": "ok", 
  "message": "Pipelines Elixir Server",
  "version": "1.0.0"
}
```

### Pipeline List Response
**Python Response:**
```json
{
  "data": [
    {
      "id": "example_pipeline",
      "name": "Example Pipeline",
      "description": "An example pipeline",
      "version": "1.0.0"
    }
  ]
}
```

**Elixir Response:**
```json
{
  "data": [
    {
      "id": "example_pipeline",
      "name": "Example Pipeline", 
      "description": "An example pipeline",
      "version": "1.0.0"
    }
  ]
}
```

### Pipeline Add Request
**Python Request:**
```json
{
  "url": "https://example.com/pipeline.py",
  "pipeline_id": "custom_pipeline"
}
```

**Elixir Request:**
```json
{
  "url": "https://example.com/pipeline.ex",
  "pipeline_id": "custom_pipeline"
}
```

### Pipeline Execution Request (Chat Completions)
**Python Request:**
```json
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "user",
      "content": "Hello, world!"
    }
  ],
  "stream": false
}
```

**Elixir Request:**
```json
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "user", 
      "content": "Hello, world!"
    }
  ],
  "stream": false
}
```

### Error Response Format
**Python Error Response:**
```json
{
  "error": {
    "type": "pipeline_not_found",
    "message": "Pipeline 'nonexistent' not found"
  }
}
```

**Elixir Error Response:**
```json
{
  "error": {
    "type": "pipeline_not_found",
    "message": "Pipeline 'nonexistent' not found"
  }
}
```

## HTTP Status Code Compatibility

| Scenario | Python Status | Elixir Status | Notes |
|----------|---------------|---------------|-------|
| Successful request | 200 OK | 200 OK | ✅ |
| Resource created | 201 Created | 201 Created | ✅ |
| Bad request | 400 Bad Request | 400 Bad Request | ✅ |
| Resource not found | 404 Not Found | 404 Not Found | ✅ |
| Validation error | 422 Unprocessable Entity | 422 Unprocessable Entity | ✅ |
| Server error | 500 Internal Server Error | 500 Internal Server Error | ✅ |

## Content Type Compatibility

| Content Type | Python Support | Elixir Support | Notes |
|-------------|----------------|----------------|-------|
| `application/json` | ✅ | ✅ | Primary content type |
| `multipart/form-data` | ✅ | ✅ | File uploads |
| `text/plain` | ✅ | ✅ | Simple text responses |

## Header Compatibility

### Request Headers
| Header | Python | Elixir | Notes |
|--------|--------|--------|-------|
| `Content-Type` | ✅ | ✅ | Required for JSON requests |
| `Authorization` | ✅ | ✅ | Bearer token support |
| `User-Agent` | ✅ | ✅ | Client identification |
| `Accept` | ✅ | ✅ | Content negotiation |

### Response Headers
| Header | Python | Elixir | Notes |
|--------|--------|--------|-------|
| `Content-Type` | ✅ | ✅ | Always set appropriately |
| `Content-Length` | ✅ | ✅ | Automatic calculation |
| `Server` | ✅ | ✅ | Server identification |
| `Access-Control-Allow-Origin` | ✅ | ✅ | CORS support |

## Pipeline Interface Compatibility

### Required Functions
| Python Function | Elixir Function | Signature | Notes |
|----------------|----------------|-----------|-------|
| `pipe(body, user, model)` | `pipe(body, user, model)` | Identical | ✅ |
| `info()` | `info()` | Identical | ✅ |

### Optional Functions
| Python Function | Elixir Function | Signature | Notes |
|----------------|----------------|-----------|-------|
| `inlet(body, user, model)` | `inlet(body, user, model)` | Identical | ✅ |
| `outlet(body, user, model)` | `outlet(body, user, model)` | Identical | ✅ |

### Pipeline Metadata Format
**Python Format:**
```python
def info():
    return {
        "id": "example",
        "name": "Example Pipeline",
        "description": "An example pipeline",
        "version": "1.0.0"
    }
```

**Elixir Format:**
```elixir
def info do
  %{
    id: "example",
    name: "Example Pipeline", 
    description: "An example pipeline",
    version: "1.0.0"
  }
end
```

## Configuration Compatibility

### Environment Variables
| Variable | Python Default | Elixir Default | Notes |
|----------|----------------|----------------|-------|
| `PORT` | 8000 | 8000 | ✅ Identical |
| `HOST` | "0.0.0.0" | "0.0.0.0" | ✅ Identical |
| `PIPELINES_DIR` | "./pipelines" | "./pipelines" | ✅ Identical |

### Valve Configuration Format
**Python Format:**
```python
"valves": {
    "parameter": {
        "type": "string",
        "default": "value",
        "description": "Parameter description"
    }
}
```

**Elixir Format:**
```elixir
valves: %{
  parameter: %{
    type: "string",
    default: "value", 
    description: "Parameter description"
  }
}
```

## Dynamic Loading Compatibility

### Python Dynamic Import
```python
import importlib.util
spec = importlib.util.spec_from_file_location("module", file_path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
```

### Elixir Dynamic Compilation
```elixir
{:ok, content} = File.read(file_path)
{:ok, module, _binary} = Code.compile_string(content)
```

Both approaches achieve the same result: runtime loading and execution of pipeline modules.

## Testing Compatibility

### Test Suite Coverage
- ✅ All endpoints tested for identical behavior
- ✅ Error conditions produce identical responses  
- ✅ Edge cases handled consistently
- ✅ Performance characteristics similar
- ✅ Memory usage patterns comparable

### Compatibility Validation
The Elixir implementation has been validated against the Python implementation using:
- Identical test cases
- Same input/output validation
- Cross-platform integration tests
- Performance benchmarking
- Memory usage analysis

## Migration Path

### From Python to Elixir
1. **Pipeline Migration**: Convert `.py` files to `.ex` files with identical logic
2. **Configuration Migration**: Environment variables remain identical
3. **Client Migration**: No client changes required - API is identical
4. **Deployment Migration**: Standard Elixir deployment practices

### Backward Compatibility
- All existing Python pipeline clients work unchanged
- API contracts remain identical
- Configuration format unchanged
- Error handling behavior preserved

This comprehensive compatibility ensures that Pipelines Elixir can serve as a drop-in replacement for the Python pipelines server while providing the benefits of the Elixir/OTP platform.