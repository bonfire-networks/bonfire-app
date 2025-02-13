defmodule Bonfire.Web.Views.AboutLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, _session, socket) do
    is_guest? = is_nil(current_user_id(assigns(socket)))
    current_user = current_user(assigns(socket))

    show_users =
      Bonfire.Common.Settings.get(
        [Bonfire.Web.Views.AboutLive, :include, :users],
        false
      )

    {users, page_info} =
      with true <- show_users,
           {_title, %{page_info: page_info, edges: edges}} <-
             Bonfire.UI.Me.UsersDirectoryLive.list_users(current_user, params, nil) do
        {edges, page_info}
      else
        _ -> {[], nil}
      end

    {:ok,
     socket
     |> assign(
       page: "about",
       selected_tab: :about,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(),
       page_header: false,
       is_guest?: is_guest?,
       users: users,
       page_info: page_info,
       without_sidebar: is_guest?,
       without_secondary_widgets: is_guest?,
       no_header: is_guest?,
       page_title: l("About "),
       sidebar_widgets: [
         guests: [
           secondary: [
             {Bonfire.Tag.Web.WidgetTagsLive, []},
             {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ],
         users: [
           secondary: [
             {Bonfire.Tag.Web.WidgetTagsLive, []},
             {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ]
       ]
     )}
  end

  def handle_event("load_more", attrs, socket) do
    {_title, %{page_info: page_info, edges: edges}} =
      Bonfire.UI.Me.UsersDirectoryLive.list_users(current_user(assigns(socket)), attrs, nil)

    {:noreply,
     socket
     |> assign(
       loaded: true,
       users: e(assigns(socket), :users, []) ++ edges,
       page_info: page_info
     )}
  end

  # catch if the :section id is "privacy"
  def handle_params(%{"section" => "privacy"}, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :privacy)}
  end

  def handle_params(%{"section" => "configuration"}, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :configuration)}
  end

  def handle_params(_tab, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :about)}
  end
end
