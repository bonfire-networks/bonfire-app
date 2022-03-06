defmodule Bonfire.Web.HomeLive do
  use Bonfire.Web, {:surface_view, [layout: {Bonfire.UI.Social.Web.LayoutView, "without_sidebar.html"}]}
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Common.Utils

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf, LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(_params, _session, socket) do
    welcome = Bonfire.Common.Config.get([:ui, :theme, :instance_welcome_description], "Login or register to play around")
      |> Utils.md
    welcome_title = Bonfire.Common.Config.get([:ui, :theme, :instance_welcome_title], "About")
    title = "Recent activity on this instance"
    {:ok, socket
    |> assign(
      page_title: "A Bonfire Instance",
      feed_title: title,
      welcome_title: welcome_title,
      welcome: welcome
    )}
  end


  defdelegate handle_params(params, attrs, socket), to: Bonfire.Common.LiveHandlers
  def handle_event(action, attrs, socket), do: Bonfire.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

end
