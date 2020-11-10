defmodule Bonfire.Web.Plugs.LoadSessionAuth do

  import Plug.Conn
  import Phoenix.Controller
  alias Bonfire.{Accounts, Users}
  alias CommonsPub.Accounts.Account
  alias CommonsPub.Users.User

  def init(opts), do: opts

  def call(conn, _opts), do: try_user(conn, get_session(conn, :user_id))

  defp try_user(conn, nil), do: try_account(conn, get_session(conn, :account_id))
  defp try_user(conn, id) when is_binary(id), do: try_user(conn, Users.get_for_session(id))
  defp try_user(conn, %User{}=user) do
    conn
    |> assign(:current_account, user.accounted.account)
    |> assign(:current_user, user)
  end

  defp try_account(conn, id) when is_binary(id), do: try_account(conn, Accounts.get_for_session(id))
  defp try_account(conn, account) do
    conn
    |> assign(:current_account, account)
    |> assign(:current_user, nil)
  end

end
