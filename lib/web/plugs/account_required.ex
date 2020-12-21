defmodule Bonfire.Web.Plugs.AccountRequired do

  use Bonfire.Web, :plug
  alias Bonfire.Data.Identity.Account

  def init(opts), do: opts

  def call(conn, _opts), do: check(conn.assigns[:current_account], conn)

  defp check(%Account{}, conn), do: conn
  defp check(_, conn) do
    conn
    |> clear_session()
    |> put_flash(:error, "You need to log in to view that page.")
    |> go(Routes.login_path(conn, :index))
    |> halt()
  end

  # TODO: should we preserve query strings?
  defp go(conn, path) do
    path = path <> "?" <> Query.encode(go: conn.requested_path)
    redirect(conn, to: path)
  end


end
