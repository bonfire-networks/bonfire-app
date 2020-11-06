defmodule CommonsPub.Core.Web.Router do
  use CommonsPub.Core.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CommonsPub.Core.Web.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", VoxPublica.Web do
    pipe_through :browser
    # guest visible pages
    live "/", IndexLive, :index

    live "/home", HomeLive, :home
    live "/home/@:username", HomeLive, :home_user

  end

  # include federation routes
    use ActivityPubWeb.Router

  # include routes from CommonsPub extensions
  use CommonsPub.Me.Web.Router

  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: VoxPublica.Web.Telemetry
    end
  end
end
