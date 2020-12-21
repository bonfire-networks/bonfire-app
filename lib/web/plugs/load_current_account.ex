defmodule Bonfire.Web.Plugs.LoadCurrentAccount do

  import Plug.Conn
  alias Bonfire.Me.Identity.{Accounts, Users}
  alias Bonfire.Data.Identity.User

  def init(opts), do: opts

  def call(conn, _opts), do: check(conn, get_session(conn, :account_id))

  defp check(conn, id) when is_binary(id),
    do: check(conn, Accounts.get_current(id))
  defp check(conn, account), do: assign(conn, :current_account, account)

end
