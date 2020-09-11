defmodule VoxPublica.Web.ResetPasswordLive do
  use VoxPublica.Web, :live_view
  use Phoenix.HTML
  import VoxPublica.Web.CommonHelper

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)
    {:ok, socket}
  end

end
