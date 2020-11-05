defmodule CommonsPub.Me.Web.Plugs.MustLogIn do

  import Plug.Conn
  import Phoenix.Controller
  alias CommonsPub.Me.Accounts

  def init(opts), do: opts

  def call(conn, opts) do
    id = get_session(conn, :account_id)
    if id,
      do: load(conn, id, opts),
      else: not_permitted(conn)
  end

  defp load(conn, account_id, opts) do
    if Keyword.get(opts, :load_account, false),
      do: load(conn, Accounts.get_for_session(account_id)),
      else: conn
  end

  defp load(conn, nil) do
    conn
    |> put_flash(:error, "You must log in to access this page.")
    |> delete_session(:account_id)
    |> redirect(to: "/login")
    |> halt()
  end

  defp load(conn, account), do: assign(conn, :account, account)

  defp not_permitted(conn) do
    conn
    |> put_flash(:error, "You must log in to access this page.")
    |> redirect(to: "/login")
    |> halt()
  end

end
