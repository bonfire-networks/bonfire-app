Benchee.run(
  %{
    "feed with boundaries" => fn -> Bonfire.Social.FeedActivities.feed(:local) end,
    "feed without boundaries" => fn -> Bonfire.Social.FeedActivities.feed(:local, skip_boundary_check: true) end,
    "feed with minimal join/preloads with boundaries" => fn -> Bonfire.Social.FeedActivities.feed(:local, preloads: :minimum) end,
    "feed with minimal join/preloads without boundaries" => fn -> Bonfire.Social.FeedActivities.feed(:local, skip_boundary_check: true, preloads: :minimum) end,
    # "AP:shared_outbox" => fn -> ActivityPubWeb.ObjectView.render("outbox.json", %{outbox: :shared_outbox}) end
  },
  parallel: 1,
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
