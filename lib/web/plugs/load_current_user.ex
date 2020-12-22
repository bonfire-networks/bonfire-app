defmodule Bonfire.Web.Plugs.LoadCurrentUser do

  use Bonfire.Web, :plug
  alias Bonfire.Me.Identity.Users
  alias Bonfire.Data.Identity.User

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :current_user, Users.get_current(get_session(conn, :user_id)))
  end

end
