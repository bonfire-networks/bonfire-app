defmodule CommonsPub.Me.Web.CreateUserController do
  use CommonsPub.Me.UseModule, [:web_module, :controller]
  alias CommonsPub.Users.User
  alias CommonsPub.Me.Users

  plug CommonsPub.Me.Web.Plugs.MustLogIn, load_account: true

  def index(conn, _),
    do: render(conn, "form.html", form: form(conn.assigns[:account]))

  def create(conn, params) do
    Map.get(params, "user_fields", %{})
    |> Users.create(conn.assigns[:account])
    |> case do
      {:ok, user} -> switched(conn, user)
      {:error, form} ->
         render(conn, "form.html", form: form)
    end
  end

  defp form(attrs \\ %{}, account), do: Users.changeset(:create, attrs, account)

  defp switched(conn, %User{id: _id, character: %{username: username}}) do
    conn
    |> put_flash(:info, "Welcome, #{username}, you're all ready to go!")
    |> put_session(:username, username)
    |> redirect(to: "/home/@#{username}")
  end

end
