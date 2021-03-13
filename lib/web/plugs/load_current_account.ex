defmodule Bonfire.Web.Plugs.LoadCurrentAccount do

  use Bonfire.Web, :plug
  alias Bonfire.Me.{Accounts, Users}
  alias Bonfire.Data.Identity.User

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :current_account, Accounts.get_current(get_session(conn, :account_id)))
  end

end
