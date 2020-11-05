defmodule CommonsPub.Me.Web.ChangePasswordController do
  use CommonsPub.Me.UseModule, [:web_module, :controller]

  plug CommonsPub.Me.Web.Plugs.MustLogIn, load_account: true

  def index(conn, _) do
  end

  def create(conn, _) do
  end

end
