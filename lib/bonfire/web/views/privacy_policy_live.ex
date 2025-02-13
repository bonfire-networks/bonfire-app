defmodule Bonfire.Web.Views.PrivacyPolicyLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    is_guest? = is_nil(current_user_id(assigns(socket)))
    # debug("is_guest? #{is_guest?}")

    {:ok,
     socket
     |> assign(
       is_guest?: is_guest?,
       without_sidebar: is_guest?,
       without_secondary_widgets: is_guest?,
       page: "privacy",
       nav_items: Bonfire.Common.ExtensionModule.default_nav(),
       page_title: l("Privacy policy"),
       terms: Config.get([:terms, :privacy])
     )}
  end
end
