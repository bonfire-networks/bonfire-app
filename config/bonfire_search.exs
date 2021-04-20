import Config

config :bonfire_search,
  disable_indexing: System.get_env("SEARCH_INDEXING_DISABLED", "false"),
  adapter: Bonfire.Search.Meili,
  instance: System.get_env("SEARCH_MEILI_INSTANCE", "http://search:7700"), # protocol, hostname and port
  api_key: System.get_env("MEILI_MASTER_KEY", "make-sure-to-change-me") # secret key

# for use by API client
config :tesla, adapter: Tesla.Adapter.Hackney
config :phoenix, :format_encoders, json: Jason
config :phoenix, :json_library, Jason
config :http_signatures, adapter: ActivityPub.Signature
# Configures http settings, upstream proxy etc.
config :activity_pub, :http,
  proxy_url: nil,
  send_user_agent: true,
  adapter: [
    ssl_options: [
      # Workaround for remote server certificate chain issues
      partial_chain: &:hackney_connect.partial_chain/1,
      # We don't support TLS v1.3 yet
      versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"]
    ]
  ]
