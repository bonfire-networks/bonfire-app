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
    instance_name = Config.get([:ui, :theme, :instance_name], Bonfire.Application.name())
    links = Config.get([:ui, :theme, :instance_welcome, :links], %{
      l("About Bonfire") => "https://bonfirenetworks.org/",
      l("Contribute") => "https://bonfirenetworks.org/contribute/"
    })

    {:ok, socket
    |> assign(
      selected_tab: "home",
      page_title: instance_name,
      links: links,
      sidebar_widgets: [
        users: [
          main: [
            {Bonfire.UI.Common.WidgetInstanceInfoLive, [display_banner: false]},
            {Bonfire.UI.Me.WidgetAdminsLive, []}
          ],
          secondary: [
            {Bonfire.UI.Common.WidgetLinksLive, [links: links]},
            {Bonfire.UI.Social.WidgetTagsLive, [links: links]}
          ]
        ],
        guests: [
          main: [
            {Bonfire.UI.Common.WidgetInstanceInfoLive, [display_banner: false]},
            {Bonfire.UI.Social.WidgetTimelinesLive, []},
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

  def do_handle_params(%{"tab" => "code-of-conduct" = tab} = _params, _url, socket) do
    IO.inspect(tab)
    {:noreply, assign(socket, selected_tab: "code-of-conduct")}
  end

  def do_handle_params(%{"tab" => "privacy-policy" = tab} = _params, _url, socket) do

    {:noreply, assign(socket, selected_tab: "privacy-policy")}
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
