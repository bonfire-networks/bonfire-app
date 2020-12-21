defmodule Bonfire.Web.Plugs.LoadCurrentAccountUsers do

  use Bonfire.Web, :plug
  alias Bonfire.Me.Identity.Users
  alias Bonfire.Data.Identity.Account

  def init(opts), do: opts

  def call(%{assigns: %{current_account: %Account{}=account}}=conn, _opts) do
    assign(conn, :current_account_users, Users.by_account(account))
  end

  def call(conn, _opts), do: conn

end
