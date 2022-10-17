# NOTE: make sure you populate your local with seeds first, and then copy paste this in iex
Logger.configure(level: :warn)
Benchee.run(
  %{
    "minimal join/preloads, with boundaries applied" => fn -> Bonfire.Social.FeedActivities.feed(:local, preloads: :with_object) end,
    "minimal join/preloads, without boundaries applied" => fn -> Bonfire.Social.FeedActivities.feed(:local, skip_boundary_check: true, preloads: :with_object) end,

    "caching preloads, with boundaries applied" => fn -> Bonfire.Social.FeedActivities.feed(:local) |> Bonfire.Social.Feeds.LiveHandler.preloads(with_cache: true) end,
    "caching preloads, without boundaries applied " => fn -> Bonfire.Social.FeedActivities.feed(:local, skip_boundary_check: true) |> Bonfire.Social.Feeds.LiveHandler.preloads(with_cache: true) end,

    "full join/preloads, with boundaries applied" => fn -> Bonfire.Social.FeedActivities.feed(:local, preloads: :feed) end,
    "full join/preloads, without boundaries applied" => fn -> Bonfire.Social.FeedActivities.feed(:local, skip_boundary_check: true, preloads: :feed) end,
    # "AP:shared_outbox" => fn -> ActivityPubWeb.ObjectView.render("outbox.json", %{outbox: :shared_outbox}) end
  },
  parallel: 10,
  warmup: 2,
  time: 5,
  memory_time: 2,
  reduction_time: 2,
  profile_after: true,
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.Console
  ]
)
Logger.configure(level: :debug)
