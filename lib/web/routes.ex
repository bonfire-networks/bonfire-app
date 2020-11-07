defmodule VoxPublica.Web.Routes do
  use CommonsPub.WebPhoenix, :router

  alias VoxPublica.Web.Routes.Helpers, as: Routes

  scope "/", VoxPublica.Web do
    # guest visible pages
    live "/", HomeLive, :home

    # user-only pages
    live "/home", HomeLive, :home
    live "/home/@:username", HomeLive, :home_user

  end

  # include federation routes
  use ActivityPubWeb.Router

  # include routes from CommonsPub extensions
  use CommonsPub.Me.Web.Router

end
