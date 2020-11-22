defmodule Bonfire.Web.Router do
  use Bonfire.Web, :router

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
    pipe_through :browser
    # guest visible pages
    live "/", HomeLive, :home
  end

  scope "/", Bonfire.Me.Web do
    pipe_through :browser
    pipe_through :guest_only
    resources "/login", LoginController, only: [:index, :create]
    resources "/confirm-email", ConfirmEmailController, only: [:index, :create, :show]
    resources "/signup", SignupController, only: [:index, :create]
  end

  scope "/", Bonfire.Web do
    pipe_through :browser
    pipe_through :auth_required
    # user-only pages
    live "/~", HomeLive, :home
    live "/~@:username", HomeLive, :home_user
    resources "/logout", LogoutController, only: [:index, :create]
 end

  # include federation routes
  use ActivityPubWeb.Router

  if Mix.env() in [:dev, :test] do
    scope "/" do
      pipe_through :browser
      if Code.ensure_loaded?(Phoenix.LiveDashboard.Router) do
        import Phoenix.LiveDashboard.Router
        live_dashboard "/dashboard", metrics: Bonfire.Web.Telemetry
      end
      if Code.ensure_loaded?(Bamboo.SentEmailViewerPlug) do
        forward "/emails", Bamboo.SentEmailViewerPlug
      end
    end
  end
end
