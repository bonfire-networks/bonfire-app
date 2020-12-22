defmodule Bonfire.Web.Plugs.LoadCurrentUser do

  import Plug.Conn
  alias Bonfire.Me.Identity.Users
  alias Bonfire.Data.Identity.User

  def init(opts), do: opts

  def call(conn, _opts), do: check(conn, get_session(conn, :user_id))

  defp check(conn, id) when is_binary(id),
    do: check(conn, Users.get_current(id, Map.get(conn.assigns, :current_account)))
  defp check(conn, {:ok, me}), do: assign(conn, :current_user, me)

end
