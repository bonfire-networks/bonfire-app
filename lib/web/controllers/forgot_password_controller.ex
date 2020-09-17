defmodule VoxPublica.Web.ForgotPasswordController do
  use VoxPublica.Web, :controller

  plug MustBeGuest

  def index(conn, _) do
  end

  def create(conn, _) do
  end

end
