defmodule Bonfire.Web.Plugs.AdminRequired do

  use Bonfire.Web, :plug

  def init(opts), do: opts


  def call(conn, opts), do: Bonfire.Web.Plugs.AccountRequired.call(conn, opts)

  # defp not_permitted(conn) do
  #   conn
  #   |> put_flash(:error, "That page is only accessible if you log in.")
  #   |> redirect(to: "/login")
  #   |> halt()
  # end

end
