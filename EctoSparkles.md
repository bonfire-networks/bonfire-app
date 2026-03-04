# EctoSparkles

Some helpers to sparkle on top of [Ecto](https://hexdocs.pm/ecto/Ecto.html) 

- [`EctoSparkles.proload/3`](#proload-documentation) and `EctoSparkles.join_preload/2` to join and preload associations with less verbosity
- [`EctoSparkles.reusable_join/5`](#reusable_join-documentation) to avoid duplicating joins 
- `EctoSparkles.Migrator` to run migrations, rollbacks, etc in a release and `EctoSparkles.AutoMigrator` to automatically run them at startup.
- `EctoSparkles.DataMigration`: a behaviour implemented for data migrations (generally backfills).
- `EctoSparkles.Log` to log slow or possible N+1 queries with telemetry (showing stacktraces)
- `EctoSparkles.Changesets.Errors` to generate readable errors for changesets

NOTE: you need to put something like `config :ecto_sparkles, :otp_app, :your_otp_app_name` in your app's config.


## `proload` documentation

A macro which tells Ecto to perform a join and preload of associations.

By default, Ecto preloads associations using a separate query for each association, which can degrade performance.

You can make it run faster by using a combination of join/preload, but that requires a bit of boilerplate (see examples below).

### Examples using standard Ecto
```
  query
  |> join(:left, [o, activity: activity], assoc(:object), as: :object)
  |> preload([l, activity: activity, object: object], activity: {activity, [object: object]})
```

Ecto requires calling three different functions for this operation: `Query.join/4`, `Query.assoc/3` and `Query.preload/2`. 

Here's another example:

```
  Invoice
  |> join(:left, [i], assoc(i, :customer), as: :customer)
  |> join(:left, [i], assoc(i, :lines), as: :lines)
  |> preload([lines: v, customers: c], lines: v, customer: c)
```

## Example using proload

With `proload`, you can accomplish this with just one line of code:

```
proload(query, activity: [:object])
```

And for the other example:
```
proload(Invoice, [:customer, :lines])
```

As a bonus, it automatically makes use of `reusable_join` so calling it multiple times with the same association has no ill effects.

## Example using join_preload

`join_preload` is `proload`'s sister macro with a slightly different syntax:

```
  join_preload(query, [:activity, :object])
```

and:
```
  Invoice
  |> join_preload(:customer)
  |> join_preload(:lines)
```


## `reusable_join` documentation

A macro similar to `Ecto.Query.join/{4,5}`, but can be called multiple times 
with the same alias.

Note that only the first join operation is performed, the subsequent ones that use the same alias
are just ignored. Also note that because of this behaviour, its mandatory to specify an alias when
using this function.

This is helpful when you need to perform a join while building queries one filter at a time,
because the same filter could be used multiple times or you could have multiple filters that
require the same join, which poses a problem with how the `filter/3` callback work, as you
need to return a dynamic with the filtering, which means that the join must have an alias,
and by default Ecto raises an error when you add multiple joins with the same alias.

To solve this, it is recommended to use this macro instead of the default `Ecto.Query.join/{4,5}`,
in which case there will be only one join in the query that can be reused by multiple filters.

### Creating reusable joins

```elixir
query
|> reusable_join(:left, [t1], t2 in "other_table", on: t1.id == t2.id, as: :other_a)
|> reusable_join(:left, [t1], t2 in "other_table", on: t1.id == t2.id, as: :other_b)
```


## Copyright 

- Copyright (c) 2021 Bonfire developers
- Copyright (c) 2020 Up Learn
- Copyright (c) 2019 Joshua Nussbaum 

- `join_preload` was originally forked from [Ecto.Preloader](https://github.com/joshnuss/ecto_preloader), licensed under WTFPL)
- `reusable_join` was originally forked from [QueryElf](https://gitlab.com/up-learn-uk/query-elf), licensed under Apache License Version 2.0
- original code licensed under Apache License Version 2.0