defmodule VoxPublica.Web.ConfirmEmailController do

  use VoxPublica.Web, :controller
  alias VoxPublica.Accounts

  def index(conn, _) do
    if get_session(conn, :account_id),
      do: redirect(conn, to: "/home"),
      else: render(conn, "form.html", requested: false, error: nil, form: form())
  end

  def show(conn, %{"id" => token}) do
    if get_session(conn, :account_id) do
      redirect(conn, to: "/home")
    else
      case Accounts.confirm_email(token) do
        {:ok, account} ->
          confirmed(conn, account)
        {:error, :confirmed, _} ->
          already_confirmed(conn)
        {:error, :expired, _} ->
          render(conn, "form.html", requested: false, error: :expired_link, form: form())
        _ ->
          render(conn, "form.html", requested: false, error: :not_found, form: form())
      end
    end
  end

  def create(conn, params) do
    if get_session(conn, :account_id) do
      redirect(conn, to: "/home")
    else
      form = Map.get(params, "confirm_email_form", %{})
      case Accounts.request_confirm_email(form(form)) do
        {:ok, _, account} ->
          render(conn, "form.html", requested: false, error: :not_found, form: form())
        {:error, :confirmed} ->
          already_confirmed(conn)
        {:error, :not_found} ->
          render(conn, "form.html", requested: false, error: :not_found, form: form())
        {:error, changeset} ->
          render(conn, "form.html", requested: false, error: nil, form: changeset)
      end
    end
  end

  defp form(params \\ %{}), do: Accounts.changeset(:confirm_email, params)

  defp confirmed(conn, account) do
    conn
    |> put_session(:account_id, account.id)
    |> put_flash(:info, "Welcome back! Thanks for confirming your email address.")
    |> redirect(to: "/home")
  end

  defp already_confirmed(conn) do
    conn
    |> put_flash(:info, "You've already confirmed your email address. You can log in now.")
    |> redirect(to: "/login")
  end
end
