import Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, level: :debug

config :elixir_pipelines,
  api_key: System.get_env("API_KEY", "0p3n-w3bu!"),
  pipelines_dir: System.get_env("PIPELINES_DIR", "pipelines")
