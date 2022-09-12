import Config

config :bonfire_search,
  disable_indexing: System.get_env("SEARCH_INDEXING_DISABLED", "false"),
  adapter: Bonfire.Search.Meili,
  # protocol, hostname and port
  instance: System.get_env("SEARCH_MEILI_INSTANCE", "http://search:7700"),
  # secret key
  api_key: System.get_env("MEILI_MASTER_KEY", "make-sure-to-change-me")

# for use by API client
config :tesla, adapter: Tesla.Adapter.Hackney
config :phoenix, :format_encoders, json: Jason
config :phoenix, :json_library, Jason
