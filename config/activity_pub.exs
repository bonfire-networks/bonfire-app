use Mix.Config

config :activity_pub, :adapter, Bonfire.Federate.ActivityPub.Adapter
config :activity_pub, :repo, Bonfire.Repo

config :nodeinfo, :adapter, Bonfire.Federate.ActivityPub.NodeinfoAdapter

config :activity_pub, :mrf_simple,
  media_removal: [],
  media_nsfw: [],
  report_removal: [],
  accept: [],
  avatar_removal: [],
  banner_removal: []

config :activity_pub, :instance,
  hostname: "localhost",
  federation_publisher_modules: [ActivityPubWeb.Publisher],
  federation_reachability_timeout_days: 7,
  federating: true,
  rewrite_policy: []

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
