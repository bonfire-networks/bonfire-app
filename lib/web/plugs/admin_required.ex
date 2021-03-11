defmodule Bonfire.Web.Plugs.AdminRequired do

  use Bonfire.Web, :plug
  alias Bonfire.Data.Identity.User
  alias Bonfire.Web.HomeLive
  alias Bonfire.Me.Web

  def init(opts), do: opts

  def call(conn, _opts), do: check(conn.assigns[:current_user], conn)

  defp check(%User{instance_admin: %{is_instance_admin: true}}, conn), do: conn
  defp check(_, conn) do
    conn
    |> clear_session()
    |> put_flash(:error, "That page is only accessible to instance administrators.")
    |> redirect(to: Routes.live_path(conn, HomeLive))
    |> halt()
  end

end
