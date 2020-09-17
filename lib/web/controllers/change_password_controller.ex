defmodule VoxPublica.Web.ChangePasswordController do
  use VoxPublica.Web, :controller

  plug MustLogIn, load_account: true

  def index(conn, _) do
  end

  def create(conn, _) do
  end

end
