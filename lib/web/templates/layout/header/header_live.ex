defmodule VoxPublica.Web.Layout.HeaderLive do
  use CommonsPub.Core.Web, :live_component

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_params(%{"signout" => _name} = _data, _socket) do
    IO.inspect("signout!")
  end


end
