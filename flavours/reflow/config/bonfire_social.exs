import Config

config :bonfire_social,
  disabled: false

alias Bonfire.Data.Social.Post
alias Bonfire.Ecto.Acts, as: Ecto
alias Bonfire.Social.Acts.{
  Activity,
  ActivityPub,
  Boundaries,
  Caretaker,
  Creator,
  Feeds,
  LivePush,
  MeiliSearch,
  Posts,
  PostContents,
  Tags,
  Threaded,
}

config :bonfire_social, Bonfire.Social.Posts,
  epics: [
    publish: [
      # Prep: a little bit of querying and a lot of preparing changesets
      Posts.Publish,           # Create a changeset for insertion
      PostContents,            # with a sanitised body and tags extracted,
      {Caretaker,  on: :post}, # a caretaker,
      {Creator,    on: :post}, # and a creator,
      {Threaded,   on: :post}, # either in reply to something or else starting a new thread,
      {Tags,       on: :post}, # with extracted tags fully hooked up,
      {Boundaries, on: :post}, # and the appropriate boundaries established
      {Activity,   on: :post}, # summarised by an activity,
      {Feeds,      on: :post}, # appearing in feeds.

      MeiliSearch.Prepare, # Prepare for search indexing or undexing

      # Now we have a short critical section
      Ecto.Begin,
      Ecto.Work,         # Run our inserts
      Ecto.Commit,

      # These things are free to happen casually in the background.
      {LivePush, on: :post}, # Publish live feed updates via (in-memory) pubsub.

      {MeiliSearch.Queue, on: :post},       # Enqueue for indexing by meilisearch

      # Oban would rather we put these here than in the transaction
      # above because it knows better than us, obviously.
      {ActivityPub, on: :post}, # Prepare for federation and do the queue insert (oban).
    ],
    delete: [
      {Delete,     on: :post}, # create a deletion changeset
      {Boundaries, on: :post}, # clean up any boundaries specific to this post
      {Feeds,      on: :post}, # remove any activities related to us from feeds.

      MeiliSearch.Prepare, # Prepare request to unindex

      # Now we have a short critical section
      Ecto.Begin,
      Ecto.Work,         # Run our deletes
      Ecto.Commit,

      # These things are free to happen casually in the background.
      {LivePush, on: :post}, # Publish live feed updates via (in-memory) pubsub.

      {MeiliSearch.Queue, on: :post},       # Enqueue meilisearch unindex   (really an insert, because oban)

      # Oban would rather we put these here than in the transaction
      # above because it knows better than us, obviously.
      {ActivityPub, on: :post}, # Prepare for federation

    ],
  ]
