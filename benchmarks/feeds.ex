Benchee.run(
  %{
    "feed with boundaries & minimal join/preloads" => fn -> Bonfire.Social.FeedActivities.feed(:local, preloads: :with_object) end,
    "feed without boundaries & minimal join/preloads" => fn -> Bonfire.Social.FeedActivities.feed(:local, skip_boundary_check: true, preloads: :with_object) end,
    "feed with boundaries & cached preloads" => fn -> Bonfire.Social.FeedActivities.feed(:local) |> Bonfire.Social.Feeds.LiveHandler.preloads() end,
    "feed without boundaries & cached preloads" => fn -> Bonfire.Social.FeedActivities.feed(:local, skip_boundary_check: true) |> Bonfire.Social.Feeds.LiveHandler.preloads() end,
    "feed with boundaries & full join/preloads" => fn -> Bonfire.Social.FeedActivities.feed(:local, preloads: :feed) end,
    "feed without boundaries & with full join/preloads " => fn -> Bonfire.Social.FeedActivities.feed(:local, skip_boundary_check: true, preloads: :feed) end,
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
