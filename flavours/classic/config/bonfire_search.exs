import Config

# for use by API client
config :tesla, adapter: Tesla.Adapter.Hackney
config :phoenix, :format_encoders, json: Jason
config :phoenix, :json_library, Jason
