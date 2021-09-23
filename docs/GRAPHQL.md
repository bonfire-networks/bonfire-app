# Bonfire GraphQL Guide

## GraphQL Introduction

Go to http://your-app-url/api/ to start playing with the GraphQL API. The GraphiQL UI should autocomplete types, queries and mutations for you, and you can also explore the schema there.

Let's start with a simple GraphQL thoeretical query:

```graphql
query {
  greetings(limit: 10) {
    greeting
    to {
      name
    }
  }
}
```

Let's break this apart:

- `query {}` is how you retrieve information from GraphQL.
- `greetings` is a `field` within the query.
- `greetings` takes a `limit` argument, a positive integer.
- `greetings` has two fields, `greeting` and `to`.
- `to` has one `field`, `name`.

This query is asking for a list of (up to) 10 greetings and the people
they are for. Notice that the result of both `greetings` and `to` are
map/object structures with their own fields and that if the type has
multiple fields, we can select more than one field.

Here is some possible data we could get returned

```elixir
%{greetings: [
    %{greeting: "hello", to: %{ name: "dear reader"}}, # english
    %{greeting: "hallo", to: %{ name: "beste lezer"}}, # dutch
  ]}
```

Where is the magic? Typically an object type will reside in its own
table in the database, so this query is actually querying two tables
in one go. In fact, given a supporting schema, you can nest queries
arbitrarily and the backend will figure out how to run them.

The fact that you can represent arbitrarily complex queries puts quite
a lot of pressure on the backend to make it all efficient. This is
still a work in progress at this time.

## Absinthe Introduction

Every `field` is filled by a resolver. Let's take our existing query
and define a schema for it in Absinthe's query DSL:

```elixir
defmodule MyApp.Schema do
  # the schema macro language
  use Absinthe.Schema.Notation
  # where we will actually resolve the fields
  alias MyApp.Resolver

  # Our user object is pretty simple, just a name
  object :user do
    field :name, non_null(:string)
  end

  # This one is slightly more complicated, we have that nested `to`
  object :greeting do
    # the easy one
    field :greeting, non_null(:string)
    # the hard one. `edge` is the term for when we cross an object boundary.
    field :to, non_null(:user), do: resolve(&Resolver.to_edge/3)
  end

  # something to put our top level queries in, because they're just fields too!
  object :queries do
    field :greetings, non_null(list_of(non_null(:string))) do
      arg :limit, :integer # optional
      resolve &Resolver.greetings/2 # we need to manually process this one
    end
  end

end
```

There are a couple of interesting things about this:

- Sprinklings of `not_null` to require that values be present (if you
  don't return them, absinthe will get upset).
- Only two fields have explicit resolvers. Anything else will default
  to a map key lookup (which is more often than not what you want).
- `greeting.to_edge` has a `/3` resolver and `queries.greetings` a
  `/2` resolver.

To understand the last one (and partially the middle one), we must
understand how resolution works and what a parent is. The best way of
doing that is probably to look at the resolver code:

```elixir
defmodule MyApp.Resolver do

  # For purposes of this, we will just fake the data out
  defp greetings_data() do
    [ %{greeting: "hello", to: %{ name: "dear reader"}}, # english
      %{greeting: "hallo", to: %{ name: "beste lezer"}}, # dutch
    ]
  end

  # the /2 resolver takes only arguments (which in this case is just limit)
  # and an info (which we'll explain later)
  def greetings(%{limit: limit}, _info) when is_integer(limit) and limit > 0 do
    {:ok, Enum.take(greetings_data(), limit)} # absinthe expects an ok/error tuple
  end
  def greetings(_args, _info), do: {:ok, greetings_data()} # no limit

  # the /3 resolver takes an additional parent argument in first position.
  # `parent` here will be the `greeting` we are resolving `to` for.
  def to_edge(parent, args, info), do: Map.get(parent, :to)

end
```

The keen-eyed amongst you may have noticed I said the default resolver
is a map lookup and our `to_edge/3` is a map lookup too, so
technically we didn't need to write it. But then you wouldn't have an
example of a `/3` resolver! In most of the app, these will be querying
from the database, not looking up in a constant.

So for every field, a resolver function is run. It defaults to a map
lookup, but you can override it with `resolve/1`. It may or may not
have arguments. And all absinthe resolvers return an ok/error tuple.

## Patterns
