defmodule Bonfire.Common.Web.LivePlugs.AuthRequired do

  import Phoenix.LiveView

  def mount(_params, _session, socket) do
    if socket.assigns[:current_account],
      do: {:ok, socket},
      else: {:halt, socket
      |> put_flash(:error, "You must log in to access this page")
      |> redirect(to: "/login")}
  end

end
