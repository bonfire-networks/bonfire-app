# `Bonfire.API.GraphQL.GraphqlWSSocket`
[🔗](https://github.com/bonfire-networks/bonfire-app/blob/main/lib/bonfire/api/graphql/graphql_ws_socket.ex#L7)

`graphql-transport-ws` websocket transport for GraphQL subscriptions
(the protocol Ferry / graphql-ws clients speak), separate from the
Phoenix-channels `Absinthe.Phoenix.Socket` at `/api/socket`.

Auth: the client sends its bearer token in the `connection_init` payload
(graphql-ws `connectionParams`); we verify it and put `current_user` into
the Absinthe context so subscriptions can scope to the viewer.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
