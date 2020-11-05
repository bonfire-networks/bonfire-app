defmodule CommonsPub.Me.Web.LogoutController do

  use CommonsPub.Me.UseModule, [:web_module, :controller]

  def index(conn, _) do
    conn |>
    logout()
  end


  defp logout(conn) do
    conn
    |> put_session(:account_id, nil)
    |> redirect(to: "/")
  end

end
