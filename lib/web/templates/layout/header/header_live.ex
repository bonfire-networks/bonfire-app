defmodule VoxPublica.Web.Layout.HeaderLive do
  use VoxPublica.Web, :live_component
  import VoxPublica.Web.CommonHelper

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
