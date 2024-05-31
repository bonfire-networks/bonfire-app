import Config

config :activity_pub,
  sign_object_fetches: true,
  reject_unsigned: true,
  env: config_env(),
  adapter: Bonfire.Federate.ActivityPub.Adapter,
  repo: Bonfire.Common.Repo

config :nodeinfo, :adapter, Bonfire.Federate.ActivityPub.NodeinfoAdapter

config :activity_pub, :instance,
  hostname: "localhost",
  federation_publisher_modules: [ActivityPub.Federator.APPublisher],
  federation_reachability_timeout_days: 7,
  # Max. depth of reply-to and reply activities fetching on incoming federation, to prevent out-of-memory situations while fetching very long threads.
  federation_incoming_max_recursion: 10,
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

config :http_signatures, adapter: ActivityPub.Safety.Signatures

# config :tesla, adapter: Tesla.Adapter.Hackney
config :tesla, :adapter, {Tesla.Adapter.Finch, name: Bonfire.Finch}

config :activity_pub, :http,
  proxy_url: nil,
  user_agent: "Bonfire ActivityPub federation",
  send_user_agent: true,
  adapter: [
    ssl_options: [
      # Workaround for remote server certificate chain issues
      # partial_chain: &:hackney_connect.partial_chain/1,
      # We don't support TLS v1.3 yet
      versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"]
    ]
  ]

config :activity_pub, ActivityPub.Web.Endpoint,
  render_errors: [
    view: ActivityPub.Web.ErrorView,
    accepts: ~w(json),
    layout: false
  ]

config :activity_pub, :json_contexts,
  actor: [
    # TODO: expose Aliases in these fields
    movedTo: "as:movedTo",
    alsoKnownAs: %{
      "@id" => "as:alsoKnownAs",
      "@type" => "@id"
    },
    sensitive: "as:sensitive",
    # TODO
    manuallyApprovesFollowers: "as:manuallyApprovesFollowers"
  ],
  object: [
    Hashtag: "as:Hashtag",
    sensitive: "as:sensitive",
    # "conversation": "ostatus:conversation", # TODO?
    ValueFlows: "https://w3id.org/valueflows#",
    om2: "http://www.ontology-of-units-of-measure.org/resource/om-2/"
  ]

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}
