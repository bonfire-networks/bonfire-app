# Absinthe Client

`AbsintheClient` is an Elixir library to perform server-side queries on a local Absinthe-based GraphQL API.

It is a WIP adaption of `Absinthe.Phoenix.Controller` that can be used with LiveView or in any other context.

Usage:

```elixir
defmodule MyApp.Web.WidgetsLive do
  use MyApp.Web, :live_view

  use AbsintheClient, schema: Bonfire.API.GraphQL.Schema, action: [mode: :internal]

  def mount(params, session, socket) do
    widgets = awesome_widgets(socket)
    IO.inspect(widgets)

    {:ok, socket
    |> assign(
      widgets: widgets
    )}
  end

  # notice we use snakecase rather than camelcase
  @graphql """
    {
      awesome_widgets
    }
  """
  def awesome_widgets(socket), do: liveql(socket, :awesome_widgets)

end
```

## License

See [LICENSE.md](./LICENSE.md).
