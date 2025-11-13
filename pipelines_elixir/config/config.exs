# Configuration for the Pipelines Elixir application
# This file contains the main configuration settings for the application

import Config

# API Configuration
# Default API key for authentication - should be changed in production
config :pipelines_elixir,
  api_key: "0p3n-w3bu!",
  pipelines_dir: "./pipelines",
  port: 8000,
  host: "0.0.0.0"

# Logging Configuration
# Set log level based on environment variable
log_level = 
  case String.upcase(System.get_env("GLOBAL_LOG_LEVEL", "INFO")) do
    "DEBUG" -> :debug
    "INFO" -> :info
    "WARNING" -> :warning
    "ERROR" -> :error
    "CRITICAL" -> :error
    _ -> :info
  end

config :logger, level: log_level

# Import environment specific config files
import_config "#{config_env()}.exs"