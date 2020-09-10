defmodule VoxPublica.Web.ProfileLive do
  use VoxPublica.Web, :live_view
  alias VoxPublica.Web.HeroProfileLive
  alias VoxPublica.Web.ProfileNavigationLive
  alias VoxPublica.Web.ProfileAboutLive
  alias VoxPublica.Fake
  import VoxPublica.Web.CommonHelper

  @impl true
  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)
    {:ok,
     socket
     |> assign(
       page_title: "User",
       selected_tab: "about",
       user: Fake.user_live(),
       current_user: Fake.user_live()
     )}
  end

  def handle_params(%{"tab" => tab} = _params, _url, socket) do
    {:noreply,
     assign(socket,
       selected_tab: tab
     )}
  end

  def handle_params(%{} = _params, _url, socket) do
    {:noreply,
     assign(socket,
       current_user: Fake.user_live()
     )}
  end

end
