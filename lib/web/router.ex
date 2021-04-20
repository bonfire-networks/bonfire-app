defmodule Bonfire.Web.Router do
  use Bonfire.Web, :router
  # import Surface.Catalogue.Router

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

  pipeline :recyclapp do
    plug :put_root_layout, {Bonfire.Recyclapp.LayoutView, :root}
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


  # include routes for active Bonfire extensions
  use Bonfire.Me.Web.Routes
  use Bonfire.Social.Web.Routes
  # use Bonfire.Website.Web.Routes

  # include federation routes
  use ActivityPubWeb.Router

  # include nodeinfo routes
  use NodeinfoWeb.Router

  ## Below you can define routes specific to your flavour of Bonfire (which aren't handled by extensions)

  # pages anyone can view
  scope "/", Bonfire do
    pipe_through :browser
    live "/", Web.HomeLive
    # a default homepage which you can customise (at path "/")
    # can be replaced with something else (eg. bonfire_website extension or similar), in which case you may want to rename the path (eg. to "/home")
    live "/home", Web.HomeLive

    live "/error", Common.Web.ErrorLive

  end

  # pages only guests can view
  scope "/", Bonfire.Me.Web do
    pipe_through :browser
    pipe_through :guest_only

  end

  # pages you need an account to view
  scope "/", Bonfire do
    pipe_through :browser
    pipe_through :account_required

 end

  # pages you need to view as a user
  scope "/", Bonfire do
    pipe_through :browser
    pipe_through :user_required

  end

  # pages only admins can view
  scope "/settings/admin" do
    pipe_through :browser
    pipe_through :admin_required

  end

  # VF pages you need to view as a user
  scope "/bread", Bonfire.UI.ValueFlows do
    pipe_through :browser
    pipe_through :user_required
    pipe_through :bread_pub

    live "/", BreadDashboardLive
    live "/milestones", ProcessesLive
    live "/milestone/:milestone_id", ProcessLive
    live "/intent/:intent_id", ProposalLive
    live "/proposal/:proposal_id", ProposalLive
    live "/proposed_intent/:proposed_intent_id", ProposalLive

    live "/map/", MapLive
    live "/map/:id", MapLive
  end


  # VF pages you need to view as a user
  scope "/recyclapp", Bonfire.Recyclapp do
    pipe_through :browser
    pipe_through :user_required
    pipe_through :recyclapp

    live "/", RecyclappDashboardLive
    live "/settings", RecyclappSettingsLive
    live "/success/:reciprocal_id", RecyclappSuccessLive

    live "/map/", MapLive
    live "/map/:id", MapLive
  end

  # include GraphQL API
  use Bonfire.GraphQL.Router

  if Mix.env() in [:dev, :test] do
    scope "/" do
      pipe_through :browser
      if Code.ensure_loaded?(Phoenix.LiveDashboard.Router) do
        import Phoenix.LiveDashboard.Router
        live_dashboard "/settings/admin/dashboard", metrics: Bonfire.Web.Telemetry
      end
      if Code.ensure_loaded?(Bamboo.SentEmailViewerPlug) do
        forward "/emails", Bamboo.SentEmailViewerPlug
      end
      # surface_catalogue "/catalogue" <-- testing a component library for liveview
    end
  end
end
