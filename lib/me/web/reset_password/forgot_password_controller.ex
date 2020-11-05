defmodule CommonsPub.Me.Web.ForgotPasswordController do
  use CommonsPub.Me.UseModule, [:web_module, :controller]

  plug CommonsPub.Me.Web.Plugs.MustBeGuest

  def index(conn, _) do
  end

  def create(conn, _) do
  end

end
