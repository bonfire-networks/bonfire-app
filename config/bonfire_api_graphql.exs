import Config

config :bonfire_api_graphql,
  configured: true

# Every notification type the Mastodon API documents, as it names them (docs.joinmastodon.org/entities/Notification). The one list of Mastodon's type names, which `Bonfire.API.MastoCompat.Schemas.Notification.type_atom/1` and `type_name/1` translate through. Only the admin types use a `.`
config :bonfire_api_graphql, Bonfire.API.MastoCompat.Schemas.Notification,
  valid_types: [
    "mention",
    "status",
    "reblog",
    "follow",
    "follow_request",
    "favourite",
    "poll",
    "update",
    "admin.sign_up",
    "admin.report",
    "severed_relationships",
    "moderation_warning",
    "quote",
    "quoted_update",
    "added_to_collection",
    "collection_update"
  ]
