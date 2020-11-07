use Mix.Config

#### Email configuration

# You will almost certainly want to change at least some of these

alias Bonfire.Mailer

config :bonfire, Mailer,
  from_address: "noreply@voxpub.local"

# include DB schemas
import_config "cpub_schemas.exs"

# include Phoenix web server boilerplate
import_config "bonfire_web_phoenix.exs"

# include all used Bonfire extensions
import_config "bonfire_me.exs"


#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.

config :bonfire,
  ecto_repos: [Bonfire.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :activity_pub, :adapter, Bonfire.ActivityPub.Adapter
config :activity_pub, :repo, Bonfire.Repo

config :bonfire, Oban,
  repo: Bonfire.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [federator_incoming: 50, federator_outgoing: 50]

config :mime, :types, %{
  "application/activity+json" => ["activity+json"]
}

import_config "#{Mix.env()}.exs"
