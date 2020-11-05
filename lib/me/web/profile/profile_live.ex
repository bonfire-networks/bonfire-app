defmodule CommonsPub.Me.Web.ProfileLive do
  use CommonsPub.Me.UseModule, [:web_module, :live_view]
  alias CommonsPub.Me.Web.HeroProfileLive
  alias CommonsPub.Me.Web.ProfileNavigationLive
  alias CommonsPub.Me.Web.ProfileAboutLive
  alias CommonsPub.Me.Fake


  @impl true
  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)
    {:ok,
     socket
     |> assign(
       page_title: "User",
       selected_tab: "about",
       user: socket.assigns.current_user
      #  current_user: Fake.user_live()
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
      selected_tab: "about"
      #  current_user: Fake.user_live()
     )}
  end

end
