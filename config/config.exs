use Mix.Config

#### Email configuration

# You will almost certainly want to change at least some of these

alias VoxPublica.Mailer

config :vox_publica, Mailer,
  from_address: "noreply@voxpub.local"

import_config "cpub_schemas.exs"
import_config "cpub_extensions.exs"

#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.

config :vox_publica,
  ecto_repos: [VoxPublica.Repo]

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

config :mime, :types, %{
  "application/activity+json" => ["activity+json"]
}

import_config "#{Mix.env()}.exs"
