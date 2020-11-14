defmodule Bonfire.Web.Router do
  use Bonfire.Web, :router
  use ActivityPubWeb.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Bonfire.Web.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :guest_only do
    plug Bonfire.Web.Plugs.GuestOnly
  end

  pipeline :auth_required do
    plug Bonfire.Web.Plugs.AuthRequired
  end

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


  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: Bonfire.Web.Telemetry
      forward "/emails", Bamboo.SentEmailViewerPlug
    end
  end
end
