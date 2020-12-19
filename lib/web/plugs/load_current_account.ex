defmodule Bonfire.Web.Plugs.LoadCurrentAccount do

  import Plug.Conn
  alias Bonfire.Me.Identity.{Accounts, Users}
  alias Bonfire.Data.Identity.User

  def init(opts), do: opts

  def call(conn, _opts), do: try_account(conn, get_session(conn, :account_id)) #|> IO.inspect

  defp try_account(conn, id) when is_binary(id),
    do: try_account(conn, Accounts.get_current(id))

  defp try_account(conn, account) do
    conn
    |> assign(:current_account, account)
    |> assign(:current_user, nil)
  end

end
