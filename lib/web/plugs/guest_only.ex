defmodule Bonfire.Web.Plugs.GuestOnly do

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  def init(opts), do: opts

  def call(conn, opts) do
    if get_session(conn, :account_id),
      do: not_permitted(conn),
      else: conn
  end

  defp not_permitted(conn) do
    conn
    |> put_flash(:error, "That page is only accessible to guests.")
    |> redirect(to: "/_")
    |> halt()
  end

end
