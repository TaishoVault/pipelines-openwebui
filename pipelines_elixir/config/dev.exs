# Development environment configuration
import Config

# Enable debug logging in development
config :logger, level: :debug

# Development specific settings
config :pipelines_elixir,
  # Use default development settings
  port: 8000,
  host: "0.0.0.0"