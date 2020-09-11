defmodule VoxPublica.Web.ChangePasswordLive do
  use VoxPublica.Web, :live_view
  use Phoenix.HTML
  import VoxPublica.Web.CommonHelper


  def mount(%{"token" => token} = params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       token: token
     )}
  end

end
