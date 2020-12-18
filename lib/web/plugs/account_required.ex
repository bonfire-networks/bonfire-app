defmodule Bonfire.Web.Plugs.AccountRequired do

  use Bonfire.Web, :plug

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_account],
      do: conn,
      else: not_permitted(conn)
  end

  defp check(%Account{}=account

  defp not_permitted(conn) do
    conn
    |> clear_session()
    |> put_flash(:error, "You need to log in to view that page.")
    |> redirect(to: Routes.login_path(conn, :index))
    |> halt()
  end

end
