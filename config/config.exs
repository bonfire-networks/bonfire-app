use Mix.Config

config :pointers,
  search_path: [:cpub_core, :vox_publica]

# config :cpub_core, CommonsPub.Core.Pseudonym,
#   regex: ~r/[a-zA-Z_][a-zA-Z0-9_]{5,29}/, # 6-30 characters
#   canonicalise: &String.lowercase/1

# config :cpub_core, CommonsPub.Core.User,
#   has_one: [
#     pseudonym: {CommonsPub.Core.Pseudonym, foreign_key: :id},
#   ]

config :vox_publica,
  ecto_repos: [VoxPublica.Repo]

# Configures the endpoint
config :vox_publica, VoxPublica.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "g7K250qlSxhNDt5qnV6f4HFnyoD7fGUuZ8tbBF69aJCOvUIF8P0U7wnnzTqklK10",
  render_errors: [view: VoxPublica.Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: VoxPublica.PubSub,
  live_view: [signing_salt: "9vdUm+Kh"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :activity_pub, :adapter, VoxPublica.ActivityPub.Adapter
config :activity_pub, :repo, VoxPublica.Repo

config :vox_publica, Oban,
  repo: VoxPublica.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [federator_incoming: 50, federator_outgoing: 50]

import_config "#{Mix.env()}.exs"
