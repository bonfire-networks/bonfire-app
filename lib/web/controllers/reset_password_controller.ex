defmodule VoxPublica.Web.ResetPasswordController do
  use VoxPublica.Web, :controller

  plug MustBeGuest

  def index(conn, %{"token" => token}) do
  end

  def create(conn, %{"token" => token}) do
  end

end
