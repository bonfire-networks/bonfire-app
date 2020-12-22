defmodule Bonfire.Web.Plugs.UserRequired do

  use Bonfire.Web, :plug
  alias Bonfire.Data.Identity.{Account, User}
  alias Plug.Conn.Query

  def init(opts), do: opts

  def call(%{assigns: the}=conn, _opts) do
    # IO.inspect(user_required_assigns: the)
    check(the[:current_user], the[:current_account], conn)
  end

  defp check(%User{}, _account, conn), do: conn

  defp check(_user, %Account{}, conn) do
    conn
    # |> clear_session()
    |> put_flash(:info, "You must choose a user to see that page.")
    |> go(Routes.switch_user_path(conn, :index))
    |> halt()
  end

  defp check(_user, _account, conn) do
    conn
    |> clear_session()
    |> put_flash(:info, "You must log in to see that page.")
    |> go(Routes.login_path(conn, :index))
    |> halt()
  end

  # TODO: should we preserve query strings?
  defp go(%{requested_path: requested_path}=conn, path) do
    path = path <> "?" <> Query.encode(go: requested_path)
    redirect(conn, to: path)
  end

  defp go(conn, path) do
    redirect(conn, to: path)
  end
end
