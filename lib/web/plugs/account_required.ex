defmodule Bonfire.Web.Plugs.AccountRequired do

  use Bonfire.Web, :plug
  alias Bonfire.Data.Identity.Account
  alias Bonfire.Common.Web.Misc

  def init(opts), do: opts

  def call(conn, _opts), do: check(conn.assigns[:current_account], conn)

  defp check(%Account{}, conn), do: conn
  defp check(_, conn) do
    conn
    |> clear_session()
    |> put_flash(:error, "You need to log in to view that page.")
    |> redirect(to: Routes.login_path(conn, :index) <> Misc.go_query(conn))
    |> halt()
  end

end
