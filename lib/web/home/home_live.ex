defmodule Bonfire.Web.HomeLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.UI.Me.LivePlugs

  @changelog File.read!("docs/CHANGELOG.md")

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
    instance_name = Config.get([:ui, :theme, :instance_name], Bonfire.Application.name())
    links = Config.get([:ui, :theme, :instance_welcome, :links], %{
      l("About Bonfire") => "https://bonfirenetworks.org/",
      l("Contribute") => "https://bonfirenetworks.org/contribute/"
    })

    {:ok, socket
    |> assign(
      page: "home",
      selected_tab: "home",
      page_title: instance_name,
      links: links,
      changelog: @changelog,
      sidebar_widgets: [
        users: [
          main: [],
          secondary: [
            {Bonfire.UI.Common.WidgetInstanceInfoLive, [display_banner: false]},
            {Bonfire.UI.Me.WidgetAdminsLive, []},
            {Bonfire.UI.Common.WidgetLinksLive, [links: links]},
            {Bonfire.UI.Social.WidgetTagsLive, [links: links]}
          ]
        ],
        guests: [
          main: [
            {Bonfire.UI.Common.WidgetInstanceInfoLive, [display_banner: false]},
            {Bonfire.UI.Social.WidgetTimelinesLive, [page: @page]},
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

  def do_handle_params(%{"tab" => tab} = _params, _url, socket) do
    debug(tab)
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def do_handle_params(params, _url, socket) do
    debug(params, "param")

    {:noreply, socket}
  end


  # defdelegate handle_params(params, attrs, socket), to: Bonfire.UI.Common.LiveHandlers
  def handle_params(params, uri, socket) do
    # poor man's hook I guess
    with {_, socket} <- Bonfire.UI.Common.LiveHandlers.handle_params(params, uri, socket) do
      undead_params(socket, fn ->
        do_handle_params(params, uri, socket)
      end)
    end
  end

  def handle_event(action, attrs, socket), do: Bonfire.UI.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

end
