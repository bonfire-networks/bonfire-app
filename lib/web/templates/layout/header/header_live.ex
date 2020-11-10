defmodule Bonfire.Web.Layout.HeaderLive do
  use Bonfire.Web, :live_component
  import Bonfire.Utils

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
