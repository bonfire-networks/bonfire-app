defmodule VoxPublica.Web.Layout.HeaderLive do
  use VoxPublica.Web, :live_component

  alias VoxPublica.Web.HeaderMeLive

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
