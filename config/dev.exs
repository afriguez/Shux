import Config

config :shux,
  bot_token: System.get_env("SHUX_TOKEN"),
  app_id: System.get_env("SHUX_APP_ID"),
  api_token: System.get_env("SHUX_API_TOKEN"),
  username: System.get_env("SHUX_USERNAME"),
  password: System.get_env("SHUX_PASSWORD")
