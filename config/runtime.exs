import Config

config :shux,
  bot_token: System.get_env("SHUX_TOKEN"),
  app_id: System.get_env("SHUX_APP_ID")
