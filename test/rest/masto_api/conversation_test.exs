# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Messages.MastoApi.ConversationTest do
  use Bonfire.Messages.MastoApiCase, async: true

  alias Bonfire.Me.Fake
  alias Bonfire.Messages

  @moduletag :masto_api

  describe "GET /api/v1/conversations" do
    test "returns conversations for authenticated user", %{conn: conn} do
      account = Fake.fake_account!()
      me = Fake.fake_user!(account)
      other_user = Fake.fake_user!()

      # Create a conversation (message from other_user to me)
      _message = create_conversation!(other_user, me, "Hello, this is a test message")

      api_conn = masto_api_conn(conn, user: me, account: account)

      response =
        api_conn
        |> get("/api/v1/conversations")
        |> json_response(200)

      assert is_list(response)
      assert length(response) >= 1

      conversation = List.first(response)
      assert is_binary(conversation["id"])
      assert is_list(conversation["accounts"])
      assert is_boolean(conversation["unread"])
      # last_status may be nil if not loaded correctly, but should exist as key
      assert Map.has_key?(conversation, "last_status")
    end

    test "returns empty list when no conversations", %{conn: conn} do
      account = Fake.fake_account!()
      me = Fake.fake_user!(account)

      api_conn = masto_api_conn(conn, user: me, account: account)

      response =
        api_conn
        |> get("/api/v1/conversations")
        |> json_response(200)

      assert response == []
    end

    test "returns 401 when not authenticated", %{conn: conn} do
      response =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/api/v1/conversations")
        |> json_response(401)

      assert response["error"]
    end

    test "only shows my conversations, not other users'", %{conn: conn} do
      account = Fake.fake_account!()
      me = Fake.fake_user!(account)
      user_a = Fake.fake_user!()
      user_b = Fake.fake_user!()

      # Create a conversation between user_a and user_b (not involving me)
      _other_message = create_conversation!(user_a, user_b, "Private chat between A and B")

      api_conn = masto_api_conn(conn, user: me, account: account)

      response =
        api_conn
        |> get("/api/v1/conversations")
        |> json_response(200)

      # Should be empty since I'm not part of any conversation
      assert response == []
    end

    test "shows conversations where I am the sender", %{conn: conn} do
      account = Fake.fake_account!()
      me = Fake.fake_user!(account)
      recipient = Fake.fake_user!()

      # Create a conversation where I am the sender
      _message = create_conversation!(me, recipient, "Message I sent")

      api_conn = masto_api_conn(conn, user: me, account: account)

      response =
        api_conn
        |> get("/api/v1/conversations")
        |> json_response(200)

      assert is_list(response)
      assert length(response) >= 1
    end
  end

  describe "POST /api/v1/conversations/:id/read" do
    test "marks conversation as read and returns conversation", %{conn: conn} do
      account = Fake.fake_account!()
      me = Fake.fake_user!(account)
      other_user = Fake.fake_user!()

      # Create a conversation (message from other_user to me)
      message = create_conversation!(other_user, me, "Hello, unread message")

      # Get the thread_id (which is used as conversation id)
      thread_id = get_thread_id(message)

      api_conn = masto_api_conn(conn, user: me, account: account)

      response =
        api_conn
        |> post("/api/v1/conversations/#{thread_id}/read")
        |> json_response(200)

      # Should return a conversation object
      assert is_binary(response["id"])
      assert is_list(response["accounts"])
      # After marking as read, unread should be false
      assert response["unread"] == false
    end

    test "returns 401 when not authenticated", %{conn: conn} do
      # Use a random ID - doesn't matter since we expect 401 before ID check
      response =
        conn
        |> put_req_header("accept", "application/json")
        |> post("/api/v1/conversations/some_id/read")
        |> json_response(401)

      assert response["error"]
    end

    test "returns 404 for non-existent conversation", %{conn: conn} do
      account = Fake.fake_account!()
      me = Fake.fake_user!(account)

      api_conn = masto_api_conn(conn, user: me, account: account)

      response =
        api_conn
        |> post("/api/v1/conversations/01HZNONEXISTENT00000000000/read")
        |> json_response(404)

      assert response["error"]
    end

    test "returns 404 when trying to mark someone else's conversation", %{conn: conn} do
      account = Fake.fake_account!()
      me = Fake.fake_user!(account)
      user_a = Fake.fake_user!()
      user_b = Fake.fake_user!()

      # Create a conversation between user_a and user_b (not involving me)
      message = create_conversation!(user_a, user_b, "Private chat")
      thread_id = get_thread_id(message)

      api_conn = masto_api_conn(conn, user: me, account: account)

      response =
        api_conn
        |> post("/api/v1/conversations/#{thread_id}/read")
        |> json_response(404)

      assert response["error"]
    end
  end

  # Helper to extract thread_id from a message
  defp get_thread_id(message) do
    # For a new message that starts a thread, the thread_id is the message's own id
    # unless it has a replied association with a thread_id
    case message do
      %{replied: %{thread_id: thread_id}} when not is_nil(thread_id) ->
        thread_id

      %{id: id} ->
        id

      _ ->
        nil
    end
  end
end
