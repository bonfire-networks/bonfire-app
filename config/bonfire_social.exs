import Config

config :bonfire_common,
  localisation_path: "priv/localisation"

config :bonfire_social,
  enabled: true

config :bonfire,
  verb_families: [
    reply: [:reply, :respond, :annotate],
    create: [:create, :write, :message, :mention],
    react: [:like, :boost, :flag, :tag, :pin, :react],
    simple_action: [:assign, :label, :schedule, :request, :quote_request, :follow_request]
  ]

config :bonfire_social, Bonfire.Social.Activities,
  experience_display_names: %{
    write: "Write",
    respond: "Respond",
    message: "Send",
    react: "React",
    follow_request: "Request to follow",
    quote_request: "Request to quote"
  }

config :paper_trail, repo: Bonfire.Common.Repo

config :paper_trail,
  item_type: Needle.UID,
  originator_type: Needle.UID,
  originator_relationship_options: [references: :id],
  originator: [name: :user, model: Bonfire.Data.Identity.User]
