defmodule Bonfire.RuntimeConfig do
  @behaviour Bonfire.Common.ConfigModule
  def config_module, do: true

  alias Bonfire.Ecto.Acts, as: EctoActs

  @page_act_opts [on: :page, attrs: :page_attrs]
  @section_act_opts [on: :section, attrs: :section_attrs]
  @label_act_opts [on: :label, object: :object, attrs: :attrs]
  @question_act_opts [on: :question, attrs: :question_attrs]

  @doc """
  NOTE: you can override this default config in your app's runtime.exs, by placing similarly-named config keys below the `Bonfire.Common.Config.LoadExtensionsConfig.load_configs` line
  """
  def config do
    import Config

    delete_object = [
      # Create a changeset for deletion
      {Bonfire.Social.Acts.Objects.Delete, on: :object, ap_on: :ap_object},

      # mark for deletion 
      {EctoActs.Delete,
       on: :object,
       delete_extra_associations: [
         :post_content,
         :tagged
       ]},

      # Now we have a short critical section
      EctoActs.Begin,
      # Run our deletes
      EctoActs.Work,
      EctoActs.Commit,

      # Prepare for federation and add to queue (oban)
      [
        {Bonfire.Social.Acts.Federate, on: :object, ap_on: :ap_object},

        # Enqueue for un-indexing by meilisearch
        {Bonfire.Search.Acts.Queue, on: :object},

        # Delete associated media
        {Bonfire.Files.Acts.Delete, on: :delete_media}
      ]
    ]

    config :bonfire_social_graph, Bonfire.Social.Graph.Follows, []

    config :bonfire_posts, Bonfire.Posts,
      epics: [
        publish: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          Bonfire.Posts.Acts.Posts.Publish,
          # These steps are run in parallel
          [
            # with a sanitised body and tags extracted,
            {Bonfire.Social.Acts.PostContents, on: :post},

            # possibly occurring in a thread,
            {Bonfire.Social.Acts.Threaded, on: :post}
          ],
          # These steps are run in parallel and require the outputs of the previous ones
          [
            # halt if it looks like spam (depends on PostContents and Threaded),
            # {Bonfire.Social.Acts.AntiSpam, on: :post, mode: :halt},

            # possibly fetch contents of URLs (depends on PostContents),
            {Bonfire.Files.Acts.URLPreviews, on: :post},

            # with extracted tags/mentions fully hooked up (depends on PostContents),
            {Bonfire.Tag.Acts.Tag, on: :post},

            # maybe set as sensitive (depends on PostContents),
            {Bonfire.Social.Acts.Sensitivity, on: :post}
          ],
          # These steps are run in parallel and require the outputs of the previous ones
          [
            # possibly with uploaded/linked media (optionally depends on URLPreviews),
            {Bonfire.Files.Acts.AttachMedia, on: :post},

            # with appropriate boundaries established (depends on Threaded),
            {Bonfire.Boundaries.Acts.SetBoundaries, on: :post},

            # NOTE: the following ones are here only to avoid executing unless the rest is valid

            # summarised by an activity (possibly appearing in feeds),
            {Bonfire.Social.Acts.Activity, on: :post},
            # {Bonfire.Social.Acts.Feeds,       on: :post},

            # assign a caretaker,
            {Bonfire.Me.Acts.Caretaker, on: :post},

            # record the creator,
            {Bonfire.Me.Acts.Creator, on: :post}
          ],

          # Now we have a short critical section
          EctoActs.Begin,
          # Run our inserts
          EctoActs.Work,
          EctoActs.Commit,

          # Preload data (TODO: move preload to separate act) + Publish live feed updates via (in-memory) PubSub
          {Bonfire.Social.Acts.LivePush, on: :post},

          # These steps are run in parallel. TODO: could casually in the background (without waiting for their result, but still notifying the user of there's an error)
          [
            # Enqueue for indexing by meilisearch
            {Bonfire.Search.Acts.Queue, on: :post},

            # Oban would rather we put these here than in the transaction above
            # Prepare JSON for federation and add to queue (oban).
            {Bonfire.Social.Acts.Federate, on: :post},

            # auto-flag if it looks like spam (depends on the post already existing),
            {Bonfire.Social.Acts.AntiSpam, on: :post, mode: :flag}
          ],

          # Once the activity/object exists (including in AP db), we can apply these side effects
          {Bonfire.Tags.Acts.AutoBoost, on: :post}
        ],
        delete: delete_object
      ]

    # Generic deletion
    config :bonfire_social, Bonfire.Social.Objects,
      epics: [
        delete: delete_object
      ]

    ## PAGES
    config :bonfire_pages, Bonfire.Pages,
      epics: [
        create: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          {Bonfire.Pages.Acts.Page.Create, @page_act_opts},
          # with a sanitised body and tags extracted,
          {Bonfire.Social.Acts.PostContents, @page_act_opts},
          # a caretaker,
          {Bonfire.Me.Acts.Caretaker, @page_act_opts},
          # and a creator,
          {Bonfire.Me.Acts.Creator, @page_act_opts},
          # and possibly fetch contents of URLs,
          {Bonfire.Files.Acts.URLPreviews, @page_act_opts},
          # possibly with uploaded files,
          {Bonfire.Files.Acts.AttachMedia, @page_act_opts},
          # with extracted tags fully hooked up,
          {Bonfire.Tag.Acts.Tag, @page_act_opts},
          # and the appropriate boundaries established,
          {Bonfire.Boundaries.Acts.SetBoundaries, @page_act_opts},
          # summarised by an activity?
          # {Bonfire.Social.Acts.Activity, @page_act_opts},
          # {Bonfire.Social.Acts.Feeds,       @page_act_opts}, # appearing in feeds?

          # Now we have a short critical section
          EctoActs.Begin,
          # Run our inserts
          EctoActs.Work,
          EctoActs.Commit,

          # These things are free to happen casually in the background.
          # Publish live feed updates via (in-memory) pubsub?
          # {Bonfire.Social.Acts.LivePush, @page_act_opts},
          # Enqueue for indexing by meilisearch
          {Bonfire.Search.Acts.Queue, @page_act_opts}

          # Oban would rather we put these here than in the transaction
          # above because it knows better than us, obviously.
          # Prepare for federation and do the queue insert (oban).
          # {Bonfire.Social.Acts.Federate, @page_act_opts},

          # Once the activity/object exists, we can apply side effects
          # {Bonfire.Tags.Acts.AutoBoost, @page_act_opts}
        ]
      ]

    config :bonfire_pages, Bonfire.Pages.Sections,
      epics: [
        upsert: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          {Bonfire.Pages.Acts.Section.Upsert, @section_act_opts},
          # with a sanitised body and tags extracted,
          {Bonfire.Social.Acts.PostContents, @section_act_opts},
          # a caretaker,
          {Bonfire.Me.Acts.Caretaker, @section_act_opts},
          # and a creator,
          {Bonfire.Me.Acts.Creator, @section_act_opts},
          # and possibly fetch contents of URLs,
          {Bonfire.Files.Acts.URLPreviews, @section_act_opts},
          # possibly with uploaded files,
          {Bonfire.Files.Acts.AttachMedia, @section_act_opts},
          # with extracted tags fully hooked up,
          {Bonfire.Tag.Acts.Tag, @section_act_opts},
          # and the appropriate boundaries established,
          {Bonfire.Boundaries.Acts.SetBoundaries, @section_act_opts},
          # summarised by an activity?
          # {Bonfire.Social.Acts.Activity, @section_act_opts},
          # {Bonfire.Social.Acts.Feeds,       @section_act_opts}, # appearing in feeds?

          # Now we have a short critical section
          EctoActs.Begin,
          # Run our inserts
          EctoActs.Work,
          EctoActs.Commit,

          # These things are free to happen casually in the background.
          # Publish live feed updates via (in-memory) pubsub?
          # {LivePush, @section_act_opts},
          # Enqueue for indexing by meilisearch
          {Bonfire.Search.Acts.Queue, @section_act_opts}

          # Oban would rather we put these here than in the transaction
          # above because it knows better than us, obviously.
          # Prepare for federation and do the queue insert (oban).
          # {Bonfire.Social.Acts.Federate, @section_act_opts},

          # Once the activity/object exists, we can apply side effects
          # {Bonfire.Tags.Acts.AutoBoost, @section_act_opts}
        ]
      ]

    config :bonfire_poll, Bonfire.Poll.Questions,
      epics: [
        create: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          {Bonfire.Poll.Question.Create, @question_act_opts},
          # with a sanitised body and tags extracted,
          {Bonfire.Social.Acts.PostContents, @question_act_opts},
          # a caretaker,
          {Bonfire.Me.Acts.Caretaker, @question_act_opts},
          # and a creator,
          {Bonfire.Me.Acts.Creator, @question_act_opts},
          # and possibly fetch contents of URLs,
          {Bonfire.Files.Acts.URLPreviews, @question_act_opts},
          # possibly with uploaded files,
          {Bonfire.Files.Acts.AttachMedia, @question_act_opts},
          # with extracted tags fully hooked up,
          {Bonfire.Tag.Acts.Tag, @question_act_opts},
          # and the appropriate boundaries established,
          {Bonfire.Boundaries.Acts.SetBoundaries, @question_act_opts},
          # summarised by an activity?
          {Bonfire.Social.Acts.Activity, @question_act_opts},
          # appearing in feeds?
          {Bonfire.Social.Acts.Feeds, @question_act_opts},

          # Now we have a short critical section
          EctoActs.Begin,
          # Run our inserts
          EctoActs.Work,
          EctoActs.Commit,

          # These things are free to happen casually in the background.
          # Publish live feed updates via (in-memory) pubsub?
          # {LivePush, @question_act_opts},
          # Enqueue for indexing by meilisearch
          {Bonfire.Search.Acts.Queue, @question_act_opts},

          # Oban would rather we put these here than in the transaction
          # above because it knows better than us, obviously.
          # Prepare for federation and do the queue insert (oban).
          {Bonfire.Social.Acts.Federate, @question_act_opts},

          # Once the activity/object exists, we can apply side effects
          {Bonfire.Tags.Acts.AutoBoost, @question_act_opts}
        ]
      ]

    config :bonfire_label, Bonfire.Label.Labelling,
      epics: [
        label_object: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          {Bonfire.Label.Acts.LabelObject, @label_act_opts},
          # with a sanitised body and tags extracted,
          {Bonfire.Social.Acts.PostContents, @label_act_opts},
          # a caretaker,
          # {Bonfire.Me.Acts.Caretaker, @page_act_opts},
          # and a creator,
          # {Bonfire.Me.Acts.Creator, @label_act_opts},
          # and possibly fetch contents of URLs,
          {Bonfire.Files.Acts.URLPreviews, @label_act_opts},
          # possibly with metadata from previous step,
          {Bonfire.Files.Acts.AttachMedia, @label_act_opts},
          # with extracted tags fully hooked up,
          # {Bonfire.Tag.Acts.Tag, @page_act_opts},
          # and the appropriate boundaries established,
          # {Bonfire.Boundaries.Acts.SetBoundaries, @label_act_opts},
          # summarised by an activity?
          # {Bonfire.Social.Acts.Activity, @label_act_opts},
          # {Bonfire.Social.Acts.Feeds,       @label_act_opts}, # appearing in feeds?

          # Now we have a short critical section
          EctoActs.Begin,
          # Run our inserts
          EctoActs.Work,
          EctoActs.Commit,

          # These things are free to happen casually in the background.
          # Publish live feed updates via (in-memory) pubsub?
          # {Bonfire.Social.Acts.LivePush, @page_act_opts},

          # Oban would rather we put these here than in the transaction
          # above because it knows better than us, obviously.
          # Prepare for federation and do the queue insert (oban).
          {Bonfire.Social.Acts.Federate, @label_act_opts}
        ]
      ]
  end
end
