import Config

# see Bonfire.Search.RuntimeConfig for env vars configured at runtime

# for use by API client
# config :tesla, :adapter, {Tesla.Adapter.Finch, name: Bonfire.Finch}
# config :tesla, adapter: Tesla.Adapter.Hackney
# the furthest into the results a search may be asked to start: an offset past it gets an empty page, and a hint in the logs naming this key
config :bonfire_search, max_offset: 1_000

config :phoenix, :format_encoders, json: Jason
config :phoenix, :json_library, Jason
