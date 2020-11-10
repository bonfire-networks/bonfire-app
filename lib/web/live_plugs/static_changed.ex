defmodule Bonfire.Web.LivePlugs.StaticChanged do

  import Phoenix.LiveView

  def mount(_, _, socket), do: {:ok, assign(socket, :static_changed, static_changed?(socket))}

end
