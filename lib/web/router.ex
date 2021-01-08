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
    plug Bonfire.Web.Plugs.LoadCurrentUser
  end

  pipeline :guest_only do
    plug Bonfire.Web.Plugs.GuestOnly
  end

  pipeline :bread_pub do
    plug :put_root_layout, {Bonfire.UI.ValueFlows.LayoutView, :root}
  end

  pipeline :website do
    plug :put_root_layout, {Bonfire.Website.LayoutView, :root}
  end


  pipeline :account_required do
    plug Bonfire.Web.Plugs.AccountRequired
  end

  pipeline :user_required do
    plug Bonfire.Web.Plugs.UserRequired
  end

  pipeline :admin_required do
    plug Bonfire.Web.Plugs.AdminRequired
  end



  # pages anyone can view
  scope "/", Bonfire.Me.Web do
    pipe_through :browser

    live "/home", HomeLive

    live "/user/:username", ProfileLive
    live "/user/:username/circles", CirclesLive
    live "/user/:username/posts", PostsLive
    live "/user/:username/posts/:post_id", PostLive

    live "/instance", MeInstanceLive
    live "/instance/:username", MeInstanceLive

    live "/thread", ThreadLive

  end

  # pages anyone can view
  scope "/", Bonfire.Website do
    pipe_through :browser
    pipe_through :website

    live "/", HomeGuestLive
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
  scope "/", Bonfire.Me.Web do
    pipe_through :browser
    pipe_through :account_required
    resources "/switch-user", SwitchUserController, only: [:index, :show]
    resources "/create-user", CreateUserController, only: [:index, :create]

    live "/change-password", ChangePasswordLive
    live "/settings", SettingsLive
    resources "/delete", AccountDeleteController, only: [:index, :create]
    resources "/logout", LogoutController, only: [:index, :create]
 end

  # pages you need to view as a user
  scope "/", Bonfire.Me.Web do
    pipe_through :browser
    pipe_through :user_required

    live "/~", MeHomeLive
    live "/~/:username", MeHomeLive

    live "/fediverse", MeFediverseLive
    live "/fediverse/:username", MeFediverseLive

    live "/settings", UserSettingsLive

    resources "/delete", UserDeleteController, only: [:index, :create]
  end

  # pages you need to view as a user
  scope "/bread", Bonfire.UI.ValueFlows do
    pipe_through :browser
    pipe_through :user_required
    pipe_through :bread_pub

    live "/", BreadpubHomeLive
    live "/~", BreadpubHomeLive

    live "/intent/:intent_id", ProposalLive
    live "/proposal/:proposal_id", ProposalLive
    live "/proposed_intent/:proposed_intent_id", ProposalLive

    live "/map/", MapLive
    live "/map/:id", MapLive
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

  # include GraphQL API
  use Bonfire.GraphQL.Router

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
