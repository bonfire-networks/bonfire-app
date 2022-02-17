import Config

config :bonfire_social,
  disabled: false

alias Bonfire.Social.{Activities, ActivityPub, Feeds, LivePush, Posts}
alias Bonfire.Epics.Acts.Repo

config :bonfire_social, Posts,
  epics: [
    publish: [
      # Create a changeset for insertion
      Posts.PublishChangeset, # puts the changeset at the key Posts.PublishChangeset by default
      # Figure out which feeds we need to publish to
      {Feeds.TargetFeeds, changeset: Posts.PublishChangeset}, # based on the changeset above

      # *transaction klaxon*
      Repo.Begin,
      {Repo.Insert, changesets: [post: Posts.PublishChangeset]},
      Repo.Commit,

      # # We want to return an activity, so we must rearrange it so we get a post under an activity.
      {Activities.UnderObjects, objects: [activity: :post], debug: true},

      {LivePush.Activity, activity: :activity, debug: true}, # Publish live feed updates via pubsub.
      {ActivityPub.Push, activity: :activity}, # Publish to activitypub via a message queue
      Posts.MeiliIndex,  # Attempt to index via meilisearch
    ],
  ]
