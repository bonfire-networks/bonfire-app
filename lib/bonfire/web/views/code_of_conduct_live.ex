defmodule Bonfire.Web.Views.CodeOfConductLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    is_guest? = is_nil(current_user_id(assigns(socket)))

    {:ok,
     socket
     |> assign(
       page: "conduct",
       selected_tab: :conduct,
       page_title: l("Code of conduct"),
       is_guest?: is_guest?,
       without_sidebar: is_guest?,
       without_secondary_widgets: is_guest?,
       no_header: is_guest?,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(),
       terms: Config.get([:terms, :conduct])
     )}
  end
end
