defmodule Bonfire.Web.HomeLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.UI.Me.LivePlugs
  alias Bonfire.Me.Accounts

  @changelog File.read!("docs/CHANGELOG.md")

  def mount(%{"dashboard" => _} = params, session, socket) do
    live_plug(params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3
    ])
  end

  def mount(params, session, socket) do
    case Config.get([:ui, :homepage_redirect_to]) do
      url when is_binary(url) ->
        {:ok,
         socket
         |> redirect_to(url, fallback: "/?dashboard", replace: false)}

      _ ->
        mount(Map.put(params, "dashboard", nil), session, socket)
    end
  end

  defp mounted(params, _session, socket) do
    instance_name = Config.get([:ui, :theme, :instance_name], Bonfire.Application.name())

    links =
      Config.get([:ui, :theme, :instance_welcome, :links], %{
        l("About Bonfire") => "https://bonfirenetworks.org/",
        l("Contribute") => "https://bonfirenetworks.org/contribute/"
      })

    {:ok,
     socket
     |> assign(
       page: "home",
       selected_tab: "home",
       page_title: instance_name,
       links: links,
       changelog: @changelog,
       error: nil,
       form: login_form(params),
       nav_items: Bonfire.Common.ExtensionModule.default_nav(:bonfire_ui_social),
       #  nav_header: false,
      #  without_sidebar: true,
       sidebar_widgets: [
         # users: [
         #   secondary: [
         #     {Bonfire.UI.Common.WidgetInstanceInfoLive, [display_banner: false]},
         #     {Bonfire.UI.Common.WidgetLinksLive, [links: links]},
         #     {Bonfire.UI.Me.WidgetAdminsLive, []},
         #     {Bonfire.Tag.Web.WidgetTagsLive, [links: links]}
         #   ]
         # ],
         # guests: [
         #   secondary: [
         #     {Bonfire.UI.Me.LoginViewLive, [form: login_form(params), error: nil]},
         #     # {Bonfire.UI.Common.WidgetInstanceInfoLive, [display_banner: false]},
         #     # {Bonfire.UI.Common.WidgetLinksLive, [links: links]},
         #     # {Bonfire.UI.Me.WidgetAdminsLive, []},
         #     # {Bonfire.Tag.Web.WidgetTagsLive, [links: links]}
         #   ]
         # ],
       ]
     )}
  end

  defp login_form(params), do: Accounts.changeset(:login, params)

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

  def handle_event(action, attrs, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)
end
