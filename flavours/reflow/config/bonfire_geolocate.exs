import Config

config :bonfire_geolocate,
  templates_path: "lib"

config :bonfire, :js_config, mapbox_api_key: System.get_env("MAPBOX_API_KEY")
