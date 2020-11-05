defmodule VoxPublica.Web.LogoutController do

  use VoxPublica.Web, :controller
  alias VoxPublica.Accounts

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
