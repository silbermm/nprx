use Mix.Config

config :nprx,
  npr_app_id: System.get_env("NPR_APP_ID"),
  npr_app_secret: System.get_env("NPR_APP_SECRET")

import_config "#{Mix.env}.exs"
