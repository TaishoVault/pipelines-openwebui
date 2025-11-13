# Production environment configuration
import Config

# Production logging - less verbose
config :logger, level: :info

# Production specific settings
config :pipelines_elixir,
  # Production settings should be set via environment variables
  port: String.to_integer(System.get_env("PORT", "8000")),
  host: System.get_env("HOST", "0.0.0.0")