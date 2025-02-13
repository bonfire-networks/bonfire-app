defmodule Bonfire.Web.Router.Routes do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Bonfire.UI.Common.Web, :router
      # use Plug.ErrorHandler
      alias Bonfire.Common.Config
      require OrionWeb.Router
      require_if_enabled(LiveAdmin.Router)
      import_if_enabled(Bonfire.OpenID.Plugs.Authorize)

      pipeline :load_current_auth do
        if module = maybe_module(Bonfire.UI.Me.Plugs.LoadCurrentUser) do
          # plug(Bonfire.UI.Me.Plugs.LoadCurrentAccount)
          # ^ no need to call LoadCurrentAccount if also calling LoadCurrentUser
          plug(module)
        end
      end

      # please note the order matters here, because of pipelines being defined in some module and re-used in others

      # these two one required first as they define some pipelines use by other routes
      use Bonfire.UI.Common.Routes
      use Bonfire.UI.Me.Routes
      # ^ required for auth

      # include routes for active Bonfire extensions
      require Bonfire.UI.Common.RoutesModule
      Bonfire.UI.Common.RoutesModule.use_modules()

      # mastodon-compatible API
      # IO.inspect(opts, label: "router_opts")
      # if opts[:generate_open_api] !=false and module_enabled?(Bonfire.API.GraphQL.MastoCompatible.Router) do
      #   import Bonfire.API.GraphQL.MastoCompatible.Router
      #   IO.puts("Generate Masto-compatible API...")
      #   include_masto_api()
      # end

      # include federation routes
      use_many_if_enabled([ActivityPub.Web.Router, NodeinfoWeb.Router])

      # FIXME: temp workaround
      # use Bonfire.PanDoRa.Web.Routes

      # optionally include Surface Catalogue for the stylebook
      require_if_enabled(Surface.Catalogue.Router)

      import_if_enabled(Oban.Web.Router)

      # pages anyone can view
      scope "/" do
        pipe_through(:browser)
        live "/", Bonfire.Web.Views.HomeLive, as: :home, private: %{cache: false}
        # live "/explore", Bonfire.Web.ExploreLive
        # , private : %{cache: true}
        live "/about", Bonfire.Web.Views.AboutLive, private: %{cache: true}
        live "/about/:section", Bonfire.Web.Views.AboutLive, private: %{cache: true}
        live "/privacy", Bonfire.Web.Views.PrivacyPolicyLive, private: %{cache: true}
        live "/conduct", Bonfire.Web.Views.CodeOfConductLive, private: %{cache: true}
        live "/changelog", Bonfire.Web.Views.ChangelogLive, private: %{cache: true}
        live "/pandora", Bonfire.PanDoRa.Web.SearchLive, private: %{cache: false}
        live "/pandora/:section", Bonfire.PanDoRa.Web.SearchLive, private: %{cache: false}

        live "/pandora/:section/:subsection", Bonfire.PanDoRa.Web.SearchLive,
          private: %{cache: false}

        live "/pandora/:section/:subsection/:subsubsection", Bonfire.PanDoRa.Web.SearchLive,
          private: %{cache: false}

        live "/pandora/:section/:subsection/:subsubsection/:subsubsubsection",
             Bonfire.PanDoRa.Web.SearchLive,
             private: %{cache: false}

        # TEMP: for testing native apps
        live("/app", Bonfire.Web.Views.DashboardLive)

        # a default homepage which you can customise (at path "/")
        # can be replaced with something else (eg. bonfire_website extension or similar), in which case you may want to rename this default path (eg. to "/home")
        # live "/", Bonfire.Website.HomeGuestLive, as: :landing
        # live "/home", Bonfire.Web.Views.HomeLive, as: :home

        if !module_exists?(Bonfire.UI.Groups),
          do: live("/&:username", Bonfire.UI.Me.CharacterLive, as: :group)

        if !module_exists?(Bonfire.UI.Topics),
          do: live("/+:username", Bonfire.UI.Me.CharacterLive, as: Bonfire.Classify.Category)
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

      if extension_enabled?(:bonfire_ui_me) do
        # pages you need to view as a user
        scope "/" do
          pipe_through(:browser)
          pipe_through(:user_required)

          live("/dashboard", Bonfire.Web.Views.DashboardLive)
          # live("/dashboard", Bonfire.Web.Views.HomeLive, as: :dashboard)
          # live "/dashboard", Bonfire.UI.Social.FeedsLive, as: :dashboard
        end

        # pages only admins can view
        scope "/settings/admin" do
          pipe_through(:browser)
          pipe_through(:admin_required)
        end

        scope "/" do
          pipe_through(:browser_unsafe)

          # if module_enabled?(Surface.Catalogue.Router) do # FIXME - getting function surface_catalogue/1 is undefined or private
          #   Surface.Catalogue.Router.surface_catalogue "/ui/"
          # end

          if Config.env() != :test do
            pipe_through(:admin_required)

            if module_enabled?(Wobserver.Web.Router) do
              forward "/admin/system/wobserver", Wobserver.Web.Router
            end

            pipe_through(:browser)

            if module_enabled?(OrionWeb.Router) do
              OrionWeb.Router.live_orion("/admin/system/orion",
                on_mount: [
                  Bonfire.UI.Me.LivePlugs.LoadCurrentUser,
                  Bonfire.UI.Me.LivePlugs.AdminRequired
                ]
              )
            end

            if module_enabled?(LiveAdmin.Router) do
              LiveAdmin.Router.live_admin("/admin/system/data",
                resources: Needle.Tables.schema_modules(),
                ecto_repo: Bonfire.Common.Repo,
                title: "Bonfire Data Admin",
                immutable_fields: [:id, :inserted_at, :updated_at],
                label_with: :name
              )
            end

            if module_enabled?(Oban.Web.Router) do
              Oban.Web.Router.oban_dashboard("/admin/system/oban")
            end
          end

          # do
          #   for schema <- Needle.Tables.schema_modules() do
          #     LiveAdmin.Router.admin_resource "/#{schema}", schema
          #   end
          # end

          # {Bonfire.UI.Common.LivePlugs, Bonfire.UI.Me.LivePlugs.UserRequired}

          if module_enabled?(Phoenix.LiveDashboard.Router) do
            import Phoenix.LiveDashboard.Router

            live_dashboard("/admin/system",
              ecto_repos: [Bonfire.Common.Repo],
              ecto_psql_extras_options: [
                long_running_queries: [threshold: "400 milliseconds"]
              ],
              metrics: Bonfire.Common.Telemetry.Metrics,
              metrics_history:
                if(Config.env() == :dev,
                  do: {Bonfire.Common.Telemetry.Storage, :metrics_history, []}
                ),
              additional_pages: [
                oban_queues: Bonfire.Web.ObanDashboard,
                oban: Oban.LiveDashboard,
                orion: Bonfire.Web.OrionLink,
                data: Bonfire.Web.DataLink,
                flame_on: FlameOn.DashboardPage
                # _profiler: {PhoenixProfiler.Dashboard, []}
              ]
            )
          end
        end
      end

      if Config.env() in [:dev, :test] do
        scope "/" do
          pipe_through(:browser)

          if module_enabled?(Bamboo.SentEmailViewerPlug) do
            forward("/admin/emails", Bamboo.SentEmailViewerPlug)
          end
        end
      end

      # if Application.get_env(:source_inspector, :enabled, false) do
      #   Phoenix.Router.scope "/" do
      #     pipe_through(:browser)
      #     # Add a new route for the Source Inspector controller
      #     post "/_source_inspector_goto_source", SourceInspector.Controller, :goto_source
      #   end
      # end
    end
  end
end

IO.puts("Compile routes...")

defmodule Bonfire.Web.Router do
  defmodule CORS do
    use Corsica.Router,
      max_age: 600,
      allow_methods: :all,
      allow_headers: :all,
      origins: {__MODULE__, :local_origin?, [:global]}

    import Untangle

    # resource "/*"

    resource("/api/*",
      origins: "*",
      allow_credentials: true
    )

    resource("/oauth/*",
      origins: "*",
      allow_credentials: true
    )

    resource("/openid/*",
      origins: "*",
      allow_credentials: true
    )

    resource("/.well-known/*",
      origins: "*"
    )

    def local_origin?(conn, origin, _scope) do
      case Bonfire.Common.URIs.base_uri(conn) |> debug() do
        %{host: local_host} ->
          case URI.parse(origin) |> debug(origin) do
            %{host: origin_host} -> origin_host == local_host
            _ -> false
          end

        _ ->
          false
      end
    end
  end

  use Bonfire.Web.Router.Routes
  # , generate_open_api: false

  # mastodon-compatible API
  # if module_enabled?(Bonfire.API.GraphQL.MastoCompatible.Router) do
  #   import Bonfire.API.GraphQL.MastoCompatible.Router
  #   IO.puts("Generate Masto-compatible API...")
  #   include_masto_api()
  # end

  @doc "(re)generates the reverse router (useful so it can be re-generated when extensions are enabled/disabled)"
  def generate_reverse_router!(app \\ :bonfire) do
    # IO.puts(:code.priv_dir(app))
    Code.put_compiler_option(:ignore_module_conflict, true)
    Code.eval_file(Path.join(:code.priv_dir(app), "extras/router_reverse.ex"))
    Code.put_compiler_option(:ignore_module_conflict, false)
  end
end

# generate an initial version of the reverse router (note that it will be re-generated at app start and when extensions are enabled/disabled)
Bonfire.Web.Router.generate_reverse_router!(:bonfire)
