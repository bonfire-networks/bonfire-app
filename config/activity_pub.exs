import Config

config :activity_pub,
  sign_object_fetches: true,
  reject_unsigned: true,
  env: config_env(),
  adapter: Bonfire.Federate.ActivityPub.Adapter,
  repo: Bonfire.Common.Repo,
  # FEP-844e: capabilities advertised via actor generator.implements
  implements: [
    %{"href" => "https://www.w3.org/TR/activitypub/"},
    %{"href" => "https://datatracker.ietf.org/doc/html/rfc9421"}
  ],
  # Known software that validates RFC 9421 signatures, with minimum version (:any = all versions).
  # Used by nodeinfo-based format inference in Instances.maybe_infer_format_from_nodeinfo/2.
  rfc9421_software: %{
    "mastodon" => "4.5.0",
    "hollo" => :any,
    "mitra" => :any,
    "fedify" => "1.6.0"
  },
  # MLS-over-ActivityPub: types counted as MLS-related for the actor's `mls:messages` collection.
  # `object_types` are matched against an inbox activity's wrapped object type (application messages are
  # a PrivateMessage/PublicMessage object wrapped in a Create); `activity_types` against the activity's
  # own top-level type (for any MLS types delivered as bare activities). Extend per deployment.
  mls_message_object_types: ["PrivateMessage", "PublicMessage", "Welcome", "GroupInfo"],
  mls_message_activity_types: []

config :nodeinfo, :adapter, Bonfire.Federate.ActivityPub.NodeinfoAdapter

config :activity_pub, :instance,
  hostname: "localhost",
  local_login_redirect_uri: "/login?go=",
  federation_publisher_modules: [ActivityPub.Federator.APPublisher],
  # when a host is written off entirely: no deliveries are even addressed to it, and we stop fetching from it too, so the only way back is it contacting us (or an admin clearing it)
  federation_reachability_timeout_days: 15,
  # pacing of deliveries to a host that keeps failing: leave it alone for this share of however long it has been failing, never less than the grace period's worth of patience and never more than the cap. The cap doubles as how long after a host recovers before we notice, so smaller is friendlier
  federation_backoff_grace_sec: 60,
  federation_backoff_fraction: 4,
  federation_backoff_cap_sec: 10_800,
  # when a delivery is too stale to be worth making: riding the backoff curve costs a job nothing, so this is what eventually stops one to a host that stays down
  federation_delivery_max_age_days: 7,
  # Max. depth of reply-to and reply activities fetching on incoming federation, to prevent out-of-memory situations while fetching very long threads.
  federation_incoming_max_recursion: 10,
  rewrite_policy: [ActivityPub.MRF.KeywordPolicy, Bonfire.Federate.ActivityPub.BoundariesMRF],
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

config :http_signatures, adapter: ActivityPub.Safety.HTTP.Signatures

config :activity_pub, :http,
  proxy_url: nil,
  user_agent: "Bonfire federation",
  send_user_agent: true,
  adapter: [
    recv_timeout: 30_000,
    connect_timeout: 10_000,
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

config :activity_pub,
  json_contexts: %{
    "Accept" => %{
      "QuoteRequest" => "https://w3id.org/fep/044f#QuoteRequest"
    },
    "QuoteRequest" => %{
      "QuoteRequest" => "https://w3id.org/fep/044f#QuoteRequest",
      "quote" => %{
        "@id" => "https://w3id.org/fep/044f#quote",
        "@type" => "@id"
      }
    },
    "QuoteAuthorization" => %{
      "QuoteAuthorization" => "https://w3id.org/fep/044f#QuoteAuthorization",
      "gts" => "https://gotosocial.org/ns#",
      "interactingObject" => %{
        "@id" => "gts:interactingObject",
        "@type" => "@id"
      },
      "interactionTarget" => %{
        "@id" => "gts:interactionTarget",
        "@type" => "@id"
      }
    },
    actor: %{
      # TODO: expose Aliases in these fields
      "movedTo" => "as:movedTo",
      "alsoKnownAs" => %{
        "@id" => "as:alsoKnownAs",
        "@type" => "@id"
      },
      "sensitive" => "as:sensitive",
      # TODO
      "manuallyApprovesFollowers" => "as:manuallyApprovesFollowers",
      # FEP-844e: capability discovery:
      "implements" => %{
        "@id" => "https://w3id.org/fep/844e#implements",
        "@type" => "@id",
        "@container" => "@set"
      },
      # MLS-over-ActivityPub (https://swicg.github.io/activitypub-e2ee/): the `mls` prefix, the actor's
      # keyPackages collection, and the `mls:messages` collection (received MLS activities, so E2EE
      # clients can skip scanning the inbox — https://purl.archive.org/socialweb/mls#messages)
      "mls" => "https://purl.archive.org/socialweb/mls#",
      "keyPackages" => %{
        "@id" => "https://purl.archive.org/socialweb/mls#keyPackages",
        "@type" => "@id"
      },
      "mls:messages" => %{
        "@id" => "https://purl.archive.org/socialweb/mls#messages",
        "@type" => "@id"
      },
      # Mastodon-compatible featured collection (pinned posts)
      "featured" => %{
        "@id" => "http://joinmastodon.org/ns#featured",
        "@type" => "@id"
      }
    },
    object: %{
      "Hashtag" => "as:Hashtag",
      "sensitive" => "as:sensitive",
      # "conversation": "ostatus:conversation", # TODO?
      "ValueFlows" => "https://w3id.org/valueflows#",
      "om2" => "http://www.ontology-of-units-of-measure.org/resource/om-2/",
      "quote" => %{
        "@id" => "https://w3id.org/fep/044f#quote",
        "@type" => "@id"
      },
      "_misskey_quote" => "https://misskey-hub.net/ns/#_misskey_quote",
      "quoteAuthorization" => %{
        "@id" => "https://w3id.org/fep/044f#quoteAuthorization",
        "@type" => "@id"
      },
      # MLS-over-ActivityPub: KeyPackage object type and endorsement fields
      "KeyPackage" => "https://purl.archive.org/socialweb/mls#KeyPackage",
      "mlsSignature" => "https://purl.archive.org/socialweb/mls#Signature",
      "mlsSignerKeyId" => "https://purl.archive.org/socialweb/mls#SignerKeyId"
    }
  }

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}
