defmodule Bonfire.Web.Router do
  use Bonfire.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Bonfire.Web.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Bonfire.Web.Plugs.LoadCurrentAccount
  end

  pipeline :guest_only do
    plug Bonfire.Web.Plugs.GuestOnly
  end

  pipeline :account_required do
    plug Bonfire.Web.Plugs.AccountRequired
  end

  pipeline :admin_required do
    plug Bonfire.Web.Plugs.AdminRequired
  end

  # pages anyone can view
  scope "/", Bonfire.Web do
    pipe_through :browser
    live "/", HomeLive
  end

  # pages only guests can view
  scope "/", Bonfire.Me.Web do
    pipe_through :browser
    pipe_through :guest_only
    resources "/signup", SignupController, only: [:index, :create]
    resources "/confirm-email", ConfirmEmailController, only: [:index, :create, :show]
    resources "/login", LoginController, only: [:index, :create]
    resources "/forgot-password", ForgotPasswordController, only: [:index, :create]
    resources "/reset-password", ResetPasswordController, only: [:show, :update]
  end

  # pages you need an account to view
  scope "/~", Bonfire.Me.Web do
    pipe_through :browser
    pipe_through :account_required
    live "/", SwitchUserLive
    live "/create-user", CreateUserLive
    live "/change-password", ChangePasswordLive
    live "/settings", AccountSettingsLive
    resources "/delete", AccountDeleteController, only: [:index, :create]
    resources "/logout", LogoutController, only: [:index, :create]
 end

  # pages you need to view as a user
  scope "/~:as_username", Bonfire.Me.Web do
    pipe_through :browser
    pipe_through :account_required
    live "/", MeHomeLive
    live "/instance", MeInstanceLive
    live "/fediverse", MeFediverseLive
    live "/user/:username", ProfileLive
    live "/user/:username/circles", CirclesLive
    live "/user/:username/posts", PostsLive
    live "/user/:username/posts/:post_id", PostLive
    live "/settings", UserSettingsLive
    live "/thread", ThreadLive
    resources "/delete", UserDeleteController, only: [:index, :create]
  end

  # pages only admins can view
  scope "/settings" do
    pipe_through :browser
    pipe_through :admin_required
    live "/", InstanceSettingsLive
  end

  # include federation routes
  use ActivityPubWeb.Router

  # include nodeinfo routes
  use NodeinfoWeb.Router

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
