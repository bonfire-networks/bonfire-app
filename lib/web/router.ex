defmodule Bonfire.Web.Router do
  use Bonfire.UI.Common.Web, :router
  # use Plug.ErrorHandler

  alias Bonfire.Common.Config

  pipeline :load_current_auth do
    plug(Bonfire.UI.Me.Plugs.LoadCurrentAccount)
    plug(Bonfire.UI.Me.Plugs.LoadCurrentUser)
  end

  # please note the order matters here, because of pipelines being defined in some module and re-used in others

  use_if_enabled(Bonfire.UI.Common.Routes)

  use_if_enabled(Bonfire.UI.Me.Routes)

  # include routes for active Bonfire extensions (no need to comment out, they'll be skipped if not available or if disabled)
  # TODO: automatically include all active extensions
  # ui_extensions = Application.compile_env!(:bonfire, :extensions_grouped, Bonfire.Common.NavModule)
  # |> Enum.flat_map(& Application.spec(&1, :modules) || [] )
  # |> Enum.filter(& Code.ensure_loaded?(&1) and function_exported?(&1, :declare_routes, 0))
  # |> debug()
  # # quoted_use_if_enabled(ui_extensions)
  # for extension <- ui_extensions do
  #   require extension
  #   extension.__using__(nil)
  # end

  # use_if_enabled Bonfire.Website.Web.Routes

  use_if_enabled(Bonfire.UI.Social.Routes)
  use_if_enabled(Bonfire.Boundaries.Web.Routes)

  use_if_enabled(Bonfire.Pages.Web.Routes)

  use_if_enabled(Bonfire.OpenID.Web.Routes)

  use_if_enabled(Bonfire.Search.Web.Routes)
  use_if_enabled(Bonfire.Tag.Web.Routes)
  use_if_enabled(Bonfire.Classify.Web.Routes)
  use_if_enabled(Bonfire.Geolocate.Web.Routes)

  use_if_enabled(Bonfire.UI.Reflow.Routes)
  use_if_enabled(Bonfire.UI.Coordination.Routes)
  use_if_enabled(Bonfire.UI.Kanban.Routes)
  use_if_enabled(Bonfire.Breadpub.Web.Routes)
  use_if_enabled(Bonfire.Recyclapp.Routes)
  use_if_enabled(Bonfire.Upcycle.Web.Routes)

  use_if_enabled(RauversionExtension.UI.Routes)

  use_if_enabled(Bonfire.Pages.Beacon.Web.Routes)

  use_if_enabled(Bonfire.Encrypt.Web.Routes)

  use_if_enabled(Bonfire.ExtensionTemplate.Web.Routes)

  # include GraphQL API
  use_if_enabled(Bonfire.API.GraphQL.Router)

  # include federation routes
  use_if_enabled(ActivityPubWeb.Router)

  # include nodeinfo routes
  use_if_enabled(NodeinfoWeb.Router)

  # optionally include Livebook for developers
  # use_if_enabled(Bonfire.Livebook.Web.Routes)

  # optionally include Surface Catalogue for the stylebook
  require_if_enabled(Surface.Catalogue.Router)

  ## Below you can define routes specific to your flavour of Bonfire (which aren't handled by extensions)

  # pages anyone can view
  scope "/" do
    pipe_through(:browser)

    # TODO: make the homepage non-live
    live("/", Bonfire.Web.HomeLive, as: :home, private: %{cache: true})
    live("/terms/:tab", Bonfire.Web.HomeLive, private: %{cache: true})

    # a default homepage which you can customise (at path "/")
    # can be replaced with something else (eg. bonfire_website extension or similar), in which case you may want to rename this default path (eg. to "/home")
    # live "/", Bonfire.Website.HomeGuestLive, as: :landing
    # live "/home", Bonfire.Web.HomeLive, as: :home

    # get "/guest/error", Bonfire.UI.Common.ErrorController, as: :error_guest
    live("/error", Bonfire.UI.Me.ErrorLive, as: :error)
  end

  # pages only guests can view
  scope "/" do
    pipe_through(:browser)
    pipe_through(:guest_only)
  end

  # pages you need an account to view
  scope "/" do
    pipe_through(:browser)
    pipe_through(:account_required)
  end

  # pages you need to view as a user
  scope "/" do
    pipe_through(:browser)
    pipe_through(:user_required)

    live("/dashboard", Bonfire.Web.HomeLive, as: :dashboard)
    # live "/dashboard", Bonfire.UI.Social.FeedsLive, as: :dashboard
  end

  # pages only admins can view
  scope "/settings/admin" do
    pipe_through(:browser)
    pipe_through(:admin_required)
  end

  scope "/" do
    pipe_through(:browser)

    # if module_enabled?(Surface.Catalogue.Router) do # FIXME - getting function surface_catalogue/1 is undefined or private
    #   Surface.Catalogue.Router.surface_catalogue "/ui/"
    # end

    if module_enabled?(Phoenix.LiveDashboard.Router) do
      import Phoenix.LiveDashboard.Router
      pipe_through(:admin_required)

      live_dashboard("/admin/system",
        ecto_repos: [Bonfire.Common.Repo],
        ecto_psql_extras_options: [
          long_running_queries: [threshold: "400 milliseconds"]
        ],
        metrics: Bonfire.Web.Telemetry,
        # metrics: FlamegraphsWeb.Telemetry,
        additional_pages: [
          flame_on: FlameOn.DashboardPage
          # _profiler: {PhoenixProfiler.Dashboard, []}
        ]
      )
    end
  end

  if Mix.env() in [:dev, :test] do
    scope "/" do
      pipe_through(:browser)

      if module_enabled?(Bamboo.SentEmailViewerPlug) do
        forward("/admin/emails", Bamboo.SentEmailViewerPlug)
      end
    end
  end
end

# generate initial reverse router (note that it will be re-generated at app start and when extensions are enabled/disabled)
Bonfire.Web.Endpoint.generate_reverse_router!()
