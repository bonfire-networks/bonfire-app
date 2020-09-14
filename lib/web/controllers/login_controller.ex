defmodule VoxPublica.Web.LoginController do

  use VoxPublica.Web, :controller
  alias VoxPublica.Accounts

  def index(conn, _) do
    if get_session(conn, :account_id),
      do: redirect(conn, to: "/home"),
      else: render(conn, "form.html", error: nil, form: form())
  end

  def create(conn, params) do
    form = Map.get(params, "login_form", %{})
    case Accounts.login(Accounts.changeset(:login, form)) do
      {:ok, account} ->
        logged_in(account, conn)
      {:error, error} when is_atom(error) ->
        render(conn, "form.html", error: error, form: form())
      {:error, changeset} ->
        render(conn, "form.html", error: nil, form: changeset)
    end
  end

  defp form(params \\ %{}), do: Accounts.changeset(:login, params)

  defp logged_in(account, conn) do
    conn
    |> put_session(:account_id, account.id)
    |> redirect(to: "/home")
  end

end
