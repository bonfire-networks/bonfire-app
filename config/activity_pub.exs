import Config

config :activity_pub,
  sign_object_fetches: true,
  # refuse to serve our objects to a fetch that is not signed (Mastodon's "authorized fetch"); also an instance setting in the admin UI ("Require authentication from federated servers"), which wins
  reject_unsigned: false,
  env: config_env(),
  adapter: Bonfire.Federate.ActivityPub.Adapter,
  repo: Bonfire.Common.Repo,
  # FEP-844e: capabilities advertised via actor generator.implements
  implements: [
    %{"href" => "https://www.w3.org/TR/activitypub/"},
    %{"href" => "https://datatracker.ietf.org/doc/html/rfc9421"},
    %{"href" => "https://w3id.org/fep/8b32"}
  ],
  # FEP-8b32: sign what we send with an Object Integrity Proof (made by a key derived from the actor's RSA key)
  sign_object_integrity_proofs: true,
  object_integrity_cryptosuite: "eddsa-jcs-2022",
  # how a proof's `domain` is checked: `:relay` accepts our own host, or the group relaying the activity (FEP-1b12); see `ActivityPub.Safety.IntegrityProofs`
  object_integrity_domain_check: :relay,
  # the edit history Pleroma and Akkoma federate inside an edited object (`formerRepresentations`, its earlier versions): dropped on receipt unless `true`, since nothing here reads it and its origin still has it
  keep_received_edit_history: false,
  # how far a delivery is trusted by what signed it (see `ActivityPub.Safety`); a signature we cannot check counts as none
  incoming_signatures: [
    # no signature of any kind, and its origin does not serve it: `:reject` or `:accept` (also ACCEPT_UNSIGNED_ACTIVITIES=1, see `Bonfire.Federate.ActivityPub.RuntimeConfig`)
    unsigned: :reject,
    # a signature that does not hold and nothing else vouches for it, and its origin does not serve it: `:reject` or `:accept`
    invalid: :reject,
    # one signature holds and another does not: a valid HTTP signature (always the author's own server's), but the proof or LD signature in the body does not hold: `:accept` (on the HTTP signature), `:refetch` (the origin's copy instead) or `:reject`
    partly_invalid: :accept
    # an activity relayed to us (FEP-1b12): `relayed: :trust` the relayed copy, or `:verify` it by refetching from its origin. Left unset here so an older `relayed_activity_trust` setting still counts; `:trust` when neither is set
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
  # when a host is written off: deliveries and fetches to it stop, except for an occasional probe (below). It also comes back when it contacts us, or when an admin clears it
  federation_reachability_timeout_days: 15,
  # how often a written-off host is probed, so one that recovers is noticed: wait this share of however long it has been failing, never more than the cap. So about every 1.5 days at the 15-day threshold, weekly once it has been down for 70 days. The probe is the next real delivery or fetch for it, never a scheduled request, so a dead host that nothing here talks to is never contacted
  federation_dead_probe_fraction: 10,
  federation_dead_probe_cap_sec: 604_800,
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

# Objects nested in the fields of another object (an event's `location`) are stored as objects of their own, and the field keeps their id (`ActivityPub.Federator.NestedObjects`). Which fields hold objects is read from the document's `@context`: the terms it defines as IRIs, plus `include_fields`, minus `exclude_fields` (the same names as the options of one call to `NestedObjects.ingest/2`, which are added to these and win over them).
config :activity_pub, :nested_objects,
  # what is done with a nested object nobody vouched for (its own proof, or the document carrying it authenticated as its owner or by its origin), unless `include_fields` says otherwise for the field (`{field, policy}`): `:authenticate_or_store` (store it as `unverified`), `:authenticate_or_drop`, `:authenticate_or_fetch_or_store` or `:authenticate_or_fetch_or_drop`. Not fetching by default, which would slow each delivery and load other servers: whoever reads an `unverified` one can fetch it
  default_policy: :authenticate_or_store,
  # terms to ingest that no context defines as an IRI, as names, or as `{name, policy}` to set what is done with an object in that field
  include_fields: [],
  # object-valued in the vocabulary, but not ours to ingest: they name who or what a document is about or addressed to, media and tags (handled by their own extensions), and the pages, endpoints and links around a collection
  exclude_fields: [
    "type",
    "formerType",
    "actor",
    "object",
    "attributedTo",
    "audience",
    "context",
    "inReplyTo",
    "replies",
    "icon",
    "image",
    "attachment",
    "tag",
    "url",
    "to",
    "bto",
    "cc",
    "bcc",
    "first",
    "last",
    "next",
    "prev",
    "current",
    "partOf",
    "items",
    "orderedItems",
    "inbox",
    "outbox",
    "followers",
    "following",
    "members",
    "moderators",
    "liked",
    "likes",
    "shares",
    "streams",
    "endpoints",
    "sharedInbox",
    "href",
    "proxyUrl",
    "uploadMedia",
    "oauthAuthorizationEndpoint",
    "oauthTokenEndpoint",
    "provideClientKey",
    "signClientKey",
    # "alsoKnownAs",
    "Public"
  ],
  # how many remote contexts one document may make us fetch (the sender chooses the URLs)
  max_remote_contexts: 5

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
      },
      # Group rules, emitted by `AdapterUtils.group_declarations/2`. On every actor because `Utils.do_make_json_ld_context_list/1` REPLACES the `:actor` bucket rather than merging, so a per-type entry would drop everything above.
      # Verbatim from `https://join-lemmy.org/context.json`, which Mbin, PieFed and NodeBB also honour by hiding the compose button
      "lemmy" => "https://join-lemmy.org/ns#",
      "postingRestrictedToMods" => "lemmy:postingRestrictedToMods",
      # Describes JOINING where `manuallyApprovesFollowers` describes FOLLOWING, so we emit both: our `mobilizon/group_actor.json` capture has `openness: "moderated"` WITH `manuallyApprovesFollowers: false`
      "mz" => "https://mobilizon.org/ns#",
      "openness" => %{
        "@id" => "mz:openness",
        "@type" => "@id"
      },
      # A group people JOIN, as Smithereen says it (`capabilities.acceptsJoins`, which it reads to offer Join), and which a topic, followed rather than joined, leaves out
      "litepub" => "http://litepub.social/ns#",
      "capabilities" => "litepub:capabilities",
      "acceptsJoins" => "litepub:acceptsJoins",
      # FEP-9b2b (https://w3id.org/fep/9b2b), whose `broader` and `inScheme` are aliases of SKOS: a topic names the group it is in, and its scheme, `https://w3id.org/fep/9b2b#Topic`
      "broader" => %{
        "@id" => "http://www.w3.org/2004/02/skos/core#broader",
        "@type" => "@id"
      },
      "inScheme" => %{
        "@id" => "http://www.w3.org/2004/02/skos/core#inScheme",
        "@type" => "@id"
      },
      # and its inverse, which FEP-9b2b doesn't alias: a group's collection of the topics and subgroups in it
      "narrower" => %{
        "@id" => "http://www.w3.org/2004/02/skos/core#narrower",
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
      # Whether replies are allowed, said alongside `interactionPolicy` because different software reads different ones: our captures have this from Pixelfed, PieFed, PeerTube and Mobilizon. PeerTube's namespace, per `https://join-lemmy.org/context.json`
      "pt" => "https://joinpeertube.org/ns#",
      "commentsEnabled" => "pt:commentsEnabled",
      # MLS-over-ActivityPub: KeyPackage object type and endorsement fields
      "KeyPackage" => "https://purl.archive.org/socialweb/mls#KeyPackage",
      "mlsSignature" => "https://purl.archive.org/socialweb/mls#Signature",
      "mlsSignerKeyId" => "https://purl.archive.org/socialweb/mls#SignerKeyId"
    }
  }

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}
