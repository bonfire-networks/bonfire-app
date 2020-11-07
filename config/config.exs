use Mix.Config

#### Email configuration

# You will almost certainly want to change at least some of these

alias VoxPublica.Mailer

config :vox_publica, Mailer,
  from_address: "noreply@voxpub.local"

import_config "cpub_web_phoenix.exs"

import_config "cpub_schemas.exs"
import_config "cpub_extensions.exs"

#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.

config :vox_publica,
  ecto_repos: [VoxPublica.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

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
