defmodule CommonsPub.Me.Web.ResetPasswordController do
  use CommonsPub.Me.UseModule, [:web_module, :controller]

  plug CommonsPub.Me.Web.Plugs.MustBeGuest

  def index(conn, %{"token" => token}) do
  end

  def create(conn, %{"token" => token}) do
  end

end
