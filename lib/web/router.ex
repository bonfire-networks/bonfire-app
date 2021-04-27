defmodule Bonfire.Web.Router do
  use Bonfire.Web, :router
  alias Bonfire.Common.Utils
  require Utils

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

  pipeline :account_required do
    plug Bonfire.Web.Plugs.AccountRequired
  end

  pipeline :user_required do
    plug Bonfire.Web.Plugs.UserRequired
  end

  pipeline :admin_required do
    plug Bonfire.Web.Plugs.AdminRequired
  end


  # include routes for active Bonfire extensions (no need to comment out, they'll be skipped if not available or if disabled)

  Utils.use_if_enabled Bonfire.Website.Web.Routes

  Utils.use_if_enabled Bonfire.UI.Reflow.Routes
  Utils.use_if_enabled Bonfire.Breadpub.Routes
  Utils.use_if_enabled Bonfire.Recyclapp.Routes

  Utils.use_if_enabled Bonfire.Me.Web.Routes
  Utils.use_if_enabled Bonfire.Social.Web.Routes

  Utils.use_if_enabled Bonfire.Search.Web.Routes
  Utils.use_if_enabled Bonfire.Classify.Web.Routes

  # include GraphQL API
  Utils.use_if_enabled Bonfire.GraphQL.Router

  # include federation routes
  Utils.use_if_enabled ActivityPubWeb.Router

  # include nodeinfo routes
  Utils.use_if_enabled NodeinfoWeb.Router


  ## Below you can define routes specific to your flavour of Bonfire (which aren't handled by extensions)

  # pages anyone can view
  scope "/", Bonfire do
    pipe_through :browser
    # live "/", Web.HomeLive
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

  if Mix.env() in [:dev, :test] do
    scope "/" do
      pipe_through :browser

      if Utils.module_enabled?(Phoenix.LiveDashboard.Router) do
        import Phoenix.LiveDashboard.Router
        live_dashboard "/settings/admin/dashboard", metrics: Bonfire.Web.Telemetry
      end

      if Utils.module_enabled?(Bamboo.SentEmailViewerPlug) do
        forward "/emails", Bamboo.SentEmailViewerPlug
      end

      if Utils.module_enabled?(Surface.Catalogue.Router) do
        Utils.import_if_enabled Surface.Catalogue.Router
        Surface.Catalogue.Router.surface_catalogue "/catalogue"
      end
    end
  end
end
