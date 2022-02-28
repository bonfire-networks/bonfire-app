import Config

config :activity_pub, :adapter, Bonfire.Federate.ActivityPub.Adapter
config :activity_pub, :repo, Bonfire.Repo

config :nodeinfo, :adapter, Bonfire.Federate.ActivityPub.NodeinfoAdapter


config :activity_pub, :instance,
  hostname: "localhost",
  federation_publisher_modules: [ActivityPubWeb.Publisher],
  federation_reachability_timeout_days: 7,
  federating: true,
  rewrite_policy: [Bonfire.Federate.ActivityPub.BoundariesMRF],
  handle_unknown_activities: true

config :activity_pub, :boundaries,
  block: [],
  silence_them: [],
  ghost_them: []

config :activity_pub, :mrf_simple,
  reject: [],
  accept: [],
  media_removal: [],
  media_nsfw: [],
  report_removal: [],
  avatar_removal: [],
  banner_removal: []

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

config :activity_pub, ActivityPubWeb.Endpoint,
  render_errors: [view: ActivityPubWeb.ErrorView, accepts: ~w(json), layout: false]

config :activity_pub, :json_contexts, %{
    "Hashtag"=> "as:Hashtag",
    "ValueFlows" => "https://w3id.org/valueflows#",
    "om2" => "http://www.ontology-of-units-of-measure.org/resource/om-2/"
  }

config :mime, :types, %{
  "application/activity+json" => ["activity+json"],
  "application/ld+json" => ["ld+json"],
  "application/jrd+json" => ["jrd+json"]
}
