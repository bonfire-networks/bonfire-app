use Mix.Config

config :activity_pub, :adapter, Bonfire.ActivityPub.Adapter
config :activity_pub, :repo, Bonfire.Repo

config :nodeinfo, :adapter, Bonfire.NodeinfoAdapter
