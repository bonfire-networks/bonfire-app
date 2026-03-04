# Bonfire.Epics

Epics are a extensible way of structuring tasks.

This library is designed to provide a structured way to define and execute complex workflows in Elixir applications. It introduces the concept of "Epics" and "Acts" to organize and run sequences of operations.

## Key components and concepts:

- `Bonfire.Epics.Epic`: An Epic represents a complete workflow or process. It's a container that holds a sequence of Acts to be executed, along with state information, errors, and assigned values.
- `Bonfire.Epics.Act`: An Act is an individual step or operation within an Epic. Each Act is typically a module that implements a specific task or functionality.
- Execution Flow & Parallel Execution: Epics are executed by running their Acts in sequence. The library provides mechanisms to define, modify, and run these sequences. The library supports running multiple Acts in parallel for improved performance in certain scenarios.
- Shared State: An Epic can maintain state throughout its execution using the 'assigns' map, allowing data to be passed between Acts.
- Configurable: Epics can be defined in configuration, including at runtime, making it easy to set up and modify workflows without changing code.
- Database Transactions: See the `Bonfire.Ecto` library for helpers to queue changeset operations within Acts and then run them all together in a single transaction: https://github.com/bonfire-networks/bonfire_ecto
- Error Handling: The library includes built-in error handling, allowing errors to be captured and associated with specific Acts within an Epic.

This library is particularly useful for applications that need to manage complex, multi-step tasks with error handling and state management. It provides a flexible and extensible way to define, configure, and execute these processes, making it easier to maintain and modify complex workflows.

## How it works

1. Each Act is implemented as a module with a `run/2` function that performs a specific task.
2. Users define an Epic, either in code or configuration, as sequences of Acts.
3. When the Epic is run, it executes each Act in sequence (or with some Acts optionally running in parallel), maintaining state and handling errors along the way. Acts can update the Epic's state, adding errors, and assigning values that can be used by subsequent Acts.
4. After all Acts are executed, the final state of the Epic is returned, including any errors or assigned values.

## 1. How to write an Act

Write a module with a `run/2` function that takes an Epic and an Act, performs a specific task, and returns an Epic.

```elixir
defmodule Bonfire.Label.Acts.LabelObject do
  @moduledoc """
  Takes an object and label and returns a changeset for labeling that object. 
  Implements `Bonfire.Epics.Act`.

  Epic Options:
    * `:current_user` - user that will create the page, required.

  Act Options:
    * `:as` - key to where we find the label(s) to add, and then assign changeset to, default: `:label`.
    * `:object` (configurable) - id to use for the thing to label
    * `:attrs` - epic options key to find the attributes at, default: `:attrs`.
  """

  use Arrows
  import Bonfire.Epics

  @doc false
  def run(epic, act) do
    current_user = Bonfire.Common.Utils.current_user(epic.assigns[:options])

    cond do
      epic.errors != [] ->
        maybe_debug(
          epic,
          act,
          length(epic.errors),
          "Skipping due to epic errors"
        )

        epic

      not (is_struct(current_user) or is_binary(current_user)) ->
        maybe_debug(
          epic,
          act,
          current_user,
          "Skipping due to missing current_user"
        )

        epic

      true ->
        as = Keyword.get(act.options, :as) || Keyword.get(act.options, :on, :label)
        object_key = Keyword.get(act.options, :object, :object)

        label = Keyword.get(epic.assigns[:options], as, [])
        object = Keyword.get(epic.assigns[:options], object_key, nil)

        Bonfire.Label.Labelling.label_object(label, object,
          return: :changeset,
          current_user: current_user
        )
        |> Map.put(:action, :insert)
        |> Bonfire.Epics.Epic.assign(epic, as, ...)
        |> Bonfire.Ecto.Acts.Work.add(:label)
    end
  end
end
```

## 2. How to define an Epic

### Simple Epic where each Act executes sequentially

```elixir
     @page_act_opts [on: :page, attrs: :page_attrs]

     config :bonfire_pages, Bonfire.Pages,
      epics: [
        create: [
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

          # Now we open a Postgres transaction and actually do the insertions in DB
          Bonfire.Ecto.Acts.Begin,
          # Run our inserts
          Bonfire.Ecto.Acts.Work,
          Bonfire.Ecto.Acts.Commit,

          # Enqueue for indexing by meilisearch
          {Bonfire.Search.Acts.Queue, @page_act_opts}
        ]
      ]
```

### Advanced Epic, where some Acts execute in parallel

```elixir
    config :bonfire_posts, Bonfire.Posts,
      epics: [
        publish: [
          # Create a changeset for insertion
          Bonfire.Posts.Acts.Posts.Publish,
          # These next 3 Acts are run in parallel
          [
            # with a sanitised body and tags extracted,
            {Bonfire.Social.Acts.PostContents, on: :post},

            # assign a caretaker,
            {Bonfire.Me.Acts.Caretaker, on: :post},

            # record the creator,
            {Bonfire.Me.Acts.Creator, on: :post}
          ],
          # These next 4 Acts are run in parallel (they run after the previous 3 because they depend on the outputs of those Acts)
          [
            # possibly fetch contents of URLs,
            {Bonfire.Files.Acts.URLPreviews, on: :post},

            # possibly occurring in a thread,
            {Bonfire.Social.Acts.Threaded, on: :post},

            # with extracted tags/mentions fully hooked up,
            {Bonfire.Tag.Acts.Tag, on: :post},

            # maybe set as sensitive,
            {Bonfire.Social.Acts.Sensitivity, on: :post}
          ],
          # These next 3 Acts are run in parallel (they run after the previous 4 because they depend on the outputs of those Acts)
          [
            # possibly with uploaded/linked media (optionally depends on URLPreviews),
            {Bonfire.Files.Acts.AttachMedia, on: :post},

            # with appropriate boundaries established (depends on Threaded),
            {Bonfire.Boundaries.Acts.SetBoundaries, on: :post},

            # summarised by an activity (possibly appearing in feeds),
            {Bonfire.Social.Acts.Activity, on: :post}
          ],

          # Now we open a Postgres transaction and actually do the insertions in DB
          Bonfire.Ecto.Acts.Begin,
          # Run our inserts
          Bonfire.Ecto.Acts.Work,
          Bonfire.Ecto.Acts.Commit,

          # Preload data & Publish live feed updates via (in-memory) PubSub
          {Bonfire.Social.Acts.LivePush, on: :post},

          # These steps are run in parallel
          [
            # Enqueue for indexing by meilisearch
            {Bonfire.Search.Acts.Queue, on: :post},

            # Prepare JSON for federation and add to queue (oban).
            {Bonfire.Social.Acts.Federate, on: :post}
          ],

          # Once the activity/object exists (depends on federation being done)
          {Bonfire.Tags.Acts.AutoBoost, on: :post}
        ]
      ]
```

## 3. How to run an Epic

```elixir
Bonfire.Epics.run_epic(Bonfire.Posts, :publish, on: :post)
```

## Copyright and License

Copyright (c) 2022 Bonfire Contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
