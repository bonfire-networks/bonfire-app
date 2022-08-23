defmodule Bonfire.Web.Router do
  use Bonfire.UI.Common.Web, :router
  # use Plug.ErrorHandler

  alias Bonfire.Common.Config

  pipeline :basic do
    plug :fetch_session
    plug :put_root_layout, {Bonfire.UI.Common.LayoutView, :root}
  end

  pipeline :load_current_auth do
    plug Bonfire.UI.Me.Plugs.LoadCurrentAccount
    plug Bonfire.UI.Me.Plugs.LoadCurrentUser
  end

  pipeline :browser do
    plug :basic
    plug :accepts, ["html", "activity+json", "json", "ld+json"]
    plug PhoenixGon.Pipeline,
      assets: Map.new(Config.get(:js_config, []))
    plug Cldr.Plug.SetLocale, Bonfire.Common.Localise.set_locale_config()
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Bonfire.UI.Common.Plugs.ActivityPub # detect Accept headers to serve JSON or HTML
    plug :load_current_auth
    # plug Bonfire.UI.Me.Plugs.Locale # TODO: skip guessing a locale if the user has one in preferences
  end

  pipeline :guest_only do
    plug Bonfire.UI.Me.Plugs.GuestOnly
  end

  pipeline :account_required do
    plug Bonfire.UI.Me.Plugs.AccountRequired
  end

  pipeline :user_required do
    plug Bonfire.UI.Me.Plugs.UserRequired
  end

  pipeline :admin_required do
    plug Bonfire.UI.Me.Plugs.AdminRequired
  end

  use_if_enabled Bonfire.UI.Common.Routes

  # include routes for active Bonfire extensions (no need to comment out, they'll be skipped if not available or if disabled)

  # use_if_enabled Bonfire.Website.Web.Routes

  use_if_enabled Bonfire.OpenID.Web.Routes

  use_if_enabled Bonfire.UI.Me.Routes
  use_if_enabled Bonfire.UI.Social.Routes

  use_if_enabled Bonfire.Search.Web.Routes
  use_if_enabled Bonfire.Tag.Web.Routes
  use_if_enabled Bonfire.Classify.Web.Routes
  use_if_enabled Bonfire.Geolocate.Web.Routes

  use_if_enabled Bonfire.UI.Reflow.Routes
  use_if_enabled Bonfire.UI.Coordination.Routes
  use_if_enabled Bonfire.UI.Kanban.Routes
  use_if_enabled Bonfire.Breadpub.Web.Routes
  use_if_enabled Bonfire.Recyclapp.Routes
  use_if_enabled Bonfire.Upcycle.Web.Routes

  # include GraphQL API
  use_if_enabled Bonfire.API.GraphQL.Router

  # include federation routes
  use_if_enabled ActivityPubWeb.Router

  # include nodeinfo routes
  use_if_enabled NodeinfoWeb.Router

  # optionally include Livebook for developers
  use_if_enabled Bonfire.Livebook.Web.Routes

  # optionally include Surface Catalogue for the stylebook
  require_if_enabled Surface.Catalogue.Router


  ## Below you can define routes specific to your flavour of Bonfire (which aren't handled by extensions)

  # pages anyone can view
  scope "/" do
    pipe_through :browser

    # TODO: make the homepage non-live
    live "/", Bonfire.Web.HomeLive, as: :home
    live "/terms/:tab", Bonfire.Web.HomeLive

    # a default homepage which you can customise (at path "/")
    # can be replaced with something else (eg. bonfire_website extension or similar), in which case you may want to rename this default path (eg. to "/home")
    # live "/", Bonfire.Website.HomeGuestLive, as: :landing
    # live "/home", Bonfire.Web.HomeLive, as: :home

    # get "/guest/error", Bonfire.UI.Common.ErrorController, as: :error_guest
    live "/error", Bonfire.UI.Me.ErrorLive, as: :error
  end

  # pages only guests can view
  scope "/", Bonfire do
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

  scope "/" do
    pipe_through :browser

    # if module_enabled?(Surface.Catalogue.Router) do # FIXME - getting function surface_catalogue/1 is undefined or private
    #   Surface.Catalogue.Router.surface_catalogue "/ui/"
    # end

    if module_enabled?(Phoenix.LiveDashboard.Router) do
      import Phoenix.LiveDashboard.Router
      pipe_through :admin_required

      live_dashboard "/admin/system",
        ecto_repos: [Bonfire.Common.Repo],
        ecto_psql_extras_options: [long_running_queries: [threshold: "400 milliseconds"]],
        metrics: Bonfire.Web.Telemetry,
        # metrics: FlamegraphsWeb.Telemetry,
        additional_pages: [
          flame_on: FlameOn.DashboardPage
        ]
    end

  end

  if Mix.env() in [:dev, :test] do
    scope "/" do
      pipe_through :browser

      if module_enabled?(Bamboo.SentEmailViewerPlug) do
        forward "/admin/emails", Bamboo.SentEmailViewerPlug
      end
    end
  end

end
defmodule Bonfire.Web.Router.Reverse do
  import Voodoo, only: [def_reverse_router: 2]
  # import Where
  def_reverse_router :path, for: Bonfire.Web.Router

  # def path(_conn_or_socket_or_endpoint, name, _arg1) do
  #   error(name, "no path defined for type")
  #   nil
  # end
end
