defmodule Bonfire.Web.EndpointTemplate do
  alias Bonfire.Common.Config

  def session_options do
    # TODO: check that this is changeable at runtime
    # The session will be stored in the cookie and signed,
    # this means its contents can be read but not tampered with.
    # Set :encryption_salt if you would also like to encrypt it.
    [
      store: :cookie,
      key: "_bonfire_key",
      signing_salt: Config.get!(:signing_salt),
      encryption_salt: Config.get!(:encryption_salt)
    ]
  end

  defmacro __using__(_) do
    quote do
      use Bonfire.ErrorReporting # make sure this comes before the Phoenix endpoint
      use Phoenix.Endpoint, otp_app: :bonfire
      import Bonfire.Common.Extend

      use_if_enabled Absinthe.Phoenix.Endpoint

      if Application.compile_env(:bonfire, :sql_sandbox) do
        plug(Phoenix.Ecto.SQL.Sandbox)
      end

      socket "/live", Phoenix.LiveView.Socket,
        websocket: [connect_info: [:user_agent, session: Bonfire.Web.EndpointTemplate.session_options()]]

      if module_enabled?(Bonfire.API.GraphQL.UserSocket) do
        socket "/api/socket", Bonfire.API.GraphQL.UserSocket,
          websocket: true,
          longpoll: false
      end

      # plug Plug.Static,
      #   at: "/data/uploads",
      #   from: {:bonfire, "data/uploads"},
      #   gzip: false

      # Serve at "/" the static files from "priv/static" directory.
      #
      # You should set gzip to true if you are running phx.digest
      # when deploying your static files in production.
      plug Plug.Static,
        at: "/",
        from: :bonfire,
        gzip: true,
        only: ~w(assets css fonts images js favicon.ico robots.txt cache_manifest.json favicon.ico source.tar.gz)

      plug Plug.Static,
        at: "/data/uploads/",
        from: "data/uploads",
        gzip: true

      plug Plug.Static,
        at: "/",
        from: :livebook,
        gzip: true,
        only: ~w(images js)

      plug Plug.Static,
        at: "/livebook/",
        from: :livebook,
        gzip: true,
        only: ~w(css images js favicon.ico robots.txt cache_manifest.json)

      # Code reloading can be explicitly enabled under the
      # :code_reloader configuration of your endpoint.
      # FIXME: doesn't work when defined in template macro
      # if code_reloading? do
      #   socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
      #   plug Phoenix.LiveReloader
      #   plug Phoenix.CodeReloader
      #   plug Phoenix.Ecto.CheckRepoStatus, otp_app: :bonfire
      # end

      plug Phoenix.LiveDashboard.RequestLogger,
        param_key: "request_logger",
        cookie_key: "request_logger"

      plug Plug.RequestId
      plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

      plug Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Phoenix.json_library()

      plug Bonfire.ErrorReporting

      plug Plug.MethodOverride
      plug Plug.Head
      plug Plug.Session, Bonfire.Web.EndpointTemplate.session_options()

      plug Bonfire.Web.Router

    end
  end
end
