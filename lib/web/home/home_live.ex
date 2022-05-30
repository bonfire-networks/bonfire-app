defmodule Bonfire.Web.HomeLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_view
  alias Bonfire.UI.Me.LivePlugs

  def mount(params, session, socket) do
    live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(_params, _session, socket) do
    instance_name = Bonfire.Common.Config.get([:ui, :theme, :instance_name], l "An instance of Bonfire")
    links = Bonfire.Common.Config.get([:ui, :theme, :instance_welcome, :links], %{
      l("About Bonfire") => "https://bonfirenetworks.org/",
      l("Contribute") => "https://bonfirenetworks.org/contribute/"
    })

    {:ok, socket
    |> assign(
      page_title: instance_name,
      links: links,
      sidebar_widgets: [
        users: [
          main: [
            {Bonfire.UI.Common.HomeBannerLive, []},
            {Bonfire.UI.Me.WidgetAdminsLive, []}
          ],
          secondary: [
            {Bonfire.UI.Common.WidgetLinksLive, [links: links]},
            {Bonfire.UI.Social.WidgetTagsLive, [links: links]}
          ]
        ],
        guests: [
          main: [
            {Bonfire.UI.Common.HomeBannerLive, []},
            {Bonfire.UI.Me.WidgetAdminsLive, []}
          ],
          secondary: [
            {Bonfire.UI.Common.WidgetLinksLive, [links: links]},
            {Bonfire.UI.Social.WidgetTagsLive, [links: links]}
          ]
        ],
      ]
    )}
  end


  defdelegate handle_params(params, attrs, socket), to: Bonfire.UI.Common.LiveHandlers
  def handle_event(action, attrs, socket), do: Bonfire.UI.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

end
