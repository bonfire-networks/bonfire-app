use Mix.Config

config :activity_pub, :adapter, Bonfire.ActivityPub.Adapter
config :activity_pub, :repo, Bonfire.Repo

config :nodeinfo, :adapter, Bonfire.NodeinfoAdapter

config :bonfire, Bonfire.ActivityPub.Adapter,
  users_module: Bonfire.Me.Identity.Users.ActivityPub
