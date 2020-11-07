defmodule Bonfire.Web.Routes do
  use Bonfire.WebPhoenix, :router

  alias Bonfire.Web.Routes.Helpers, as: Routes

  scope "/", Bonfire.Web do
    # guest visible pages
    live "/", HomeLive, :home

    # user-only pages
    live "/home", HomeLive, :home
    live "/home/@:username", HomeLive, :home_user

  end

  # include federation routes
  use ActivityPubWeb.Router

  # include routes from CommonsPub extensions
  use Bonfire.Me.Web.Router

end
