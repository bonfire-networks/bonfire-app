if Application.compile_env(:bonfire_api_graphql, :modularity) != :disabled do
  defmodule Bonfire.Messages.Web.MastoConversationController do
    @moduledoc """
    Mastodon-compatible conversations (DM threads) endpoints.

    Implements the conversations API following Mastodon API conventions:
    - GET /api/v1/conversations - List all conversations
    - POST /api/v1/conversations/:id/read - Mark a conversation as read

    TODO (future):
    - DELETE /api/v1/conversations/:id - Remove conversation from list
    """
    use Bonfire.UI.Common.Web, :controller
    import Untangle

    alias Bonfire.Messages.API.GraphQLMasto.Adapter

    @doc "List all conversations (DM threads)"
    def index(conn, params) do
      debug(params, "GET /api/v1/conversations")

      params
      |> then(&Adapter.conversations(&1, conn))
    end

    @doc "Mark a conversation as read"
    def mark_read(conn, %{"id" => id} = params) do
      debug(params, "POST /api/v1/conversations/#{id}/read")

      %{"id" => id}
      |> then(&Adapter.mark_conversation_read(&1, conn))
    end

    # TODO: implement delete action
    # @doc "Remove a conversation from the list (does not delete messages)"
    # def delete(conn, %{"id" => id} = params) do
    #   debug(params, "DELETE /api/v1/conversations/#{id}")
    #
    #   %{"id" => id}
    #   |> then(&Adapter.delete_conversation(&1, conn))
    # end
  end
end
