# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Messages.MastoApiCase do
  @moduledoc "Test case for Mastodon API endpoint testing."

  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest

      import Bonfire.UI.Common.Testing.Helpers
      import Bonfire.Me.Fake

      import Bonfire.Messages.MastoApiCase.Helpers

      @endpoint Application.compile_env!(:bonfire, :endpoint_module)
    end
  end

  setup tags do
    Bonfire.Common.Test.Interactive.setup_test_repo(tags)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  defmodule Helpers do
    @moduledoc "Helper functions for Mastodon API testing."

    import Plug.Conn
    import Phoenix.ConnTest

    @endpoint Application.compile_env!(:bonfire, :endpoint_module)

    def masto_api_conn(conn, opts \\ []) do
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> maybe_authenticate(opts[:user], opts[:account])
    end

    defp maybe_authenticate(conn, nil, _account), do: conn

    defp maybe_authenticate(conn, user, account) do
      conn = Plug.Test.init_test_session(conn, %{})

      conn =
        if account do
          Plug.Conn.put_session(conn, :current_account_id, account.id)
        else
          conn
        end

      Plug.Conn.put_session(conn, :current_user_id, user.id)
    end

    @doc "Helper to create a conversation between two users"
    def create_conversation!(sender, receiver, message_body \\ "Test message") do
      {:ok, message} =
        Bonfire.Messages.send(sender, %{
          to_circles: [receiver.id],
          post_content: %{html_body: message_body}
        })

      message
    end
  end
end
