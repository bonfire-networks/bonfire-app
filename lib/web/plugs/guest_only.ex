defmodule Bonfire.Web.Plugs.GuestOnly do

  use Bonfire.Web, :plug
  alias Bonfire.Me.Web.SwitchUserLive

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, :account_id),
      do: not_permitted(conn),
      else: conn
  end

  defp not_permitted(conn) do
    conn
    |> put_flash(:error, "That page is only accessible to guests.")
    |> redirect(to: Routes.live_path(conn, SwitchUserLive))
    |> halt()
  end

end
