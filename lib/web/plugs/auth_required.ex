defmodule Bonfire.Web.Plugs.AuthedRequired do

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  def init(opts), do: opts

  def call(conn, opts) do
    if !get_session(conn, :account_id),
      do: not_permitted(conn),
      else: conn
  end

  defp not_permitted(conn) do
    conn
    |> put_flash(:error, "That page is only accessible if you log in.")
    |> redirect(to: "/login")
    |> halt()
  end

end
