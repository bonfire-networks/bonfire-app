import Config

# see Bonfire.Search.RuntimeConfig for env vars configured at runtime
config :bonfire_search,
  adapter: Bonfire.Search.Meili

# for use by API client
config :tesla, :adapter, {Tesla.Adapter.Finch, name: Bonfire.Finch}
# config :tesla, adapter: Tesla.Adapter.Hackney
config :phoenix, :format_encoders, json: Jason
config :phoenix, :json_library, Jason
