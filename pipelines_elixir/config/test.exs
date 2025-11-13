# Test environment configuration
import Config

# Test logging - minimal output
config :logger, level: :warning

# Test specific settings
config :pipelines_elixir,
  port: 8001,
  host: "127.0.0.1",
  pipelines_dir: "./test/fixtures/pipelines"