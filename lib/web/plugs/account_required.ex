defmodule Bonfire.Web.Plugs.AccountRequired do

  use Bonfire.Web, :plug

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, :account_id),
      do: conn,
      else: not_permitted(conn)
  end

  defp not_permitted(conn) do
    conn
    |> put_flash(:error, "You need to log in to view that page")
    |> redirect(to: Routes.login_path(conn, :index))
    |> halt()
  end

end
