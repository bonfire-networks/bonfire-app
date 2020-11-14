defmodule Bonfire.Common.Web.LivePlugs.Csrf do

  import Phoenix.LiveView

  def mount(_, %{"_csrf_token" => token}, socket), do: {:ok, assign(socket, :csrf_token, token)}
  def mount(_, _, socket), do: {:ok, socket}

end
