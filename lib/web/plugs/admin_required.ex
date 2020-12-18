defmodule Bonfire.Web.Plugs.AdminRequired do

  use Bonfire.Web, :plug
  alias Bonfire.Data.Identity.Account
  alias Bonfire.Me.Web.SwitchUserLive
  alias Bonfire.Me.Web

  def init(opts), do: opts

  def call(conn, _opts), do: check(conn.assigns[:current_account], conn)

  defp check(%Account{instance_admin: %{is_instance_admin: true}}, conn) do
  defp check(_, conn) do
    conn
    |> clear_session()
    |> put_flash(:error, "That page is only accessible to instance administrators.")
    |> redirect(to: Routes.live_path(conn, SwitchUserLive))
    |> halt()
  end

end
