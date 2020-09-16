defmodule VoxPublica.Web.SignupController do
  use VoxPublica.Web, :controller
  alias VoxPublica.Accounts

  plug MustBeGuest

  def index(conn, _) do
    if get_session(conn, :account_id),
      do: redirect(conn, to: "/home"),
      else: render(conn, "form.html", registered: false, error: nil, form: form())
  end

  def create(conn, params) do
    if get_session(conn, :account_id) do
      redirect(conn, to: "/home")
    else
      case Accounts.signup(Map.get(params, "signup_form", %{})) do
        {:ok, _account} ->
          render(conn, "form.html", registered: true)
        {:error, :taken} ->
          render(conn, "form.html", registered: false, error: :taken, form: form())
        {:error, changeset} ->
          render(conn, "form.html", registered: false, error: nil, form: changeset)
      end
    end
  end

  defp form(params \\ %{}), do: Accounts.changeset(:signup, params)

end
