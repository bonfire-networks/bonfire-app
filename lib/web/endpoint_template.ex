defmodule Bonfire.Web.EndpointTemplate do
  alias Bonfire.Common.Config

  defmacro __using__(_) do
    quote do
      # make sure this comes before the Phoenix endpoint
      use Bonfire.ErrorReporting
      import Bonfire.Common.Extend
      alias Bonfire.Web.EndpointTemplate

      use_if_enabled(Absinthe.Phoenix.Endpoint)

      if Application.compile_env(:bonfire, :sql_sandbox) do
        plug(Phoenix.Ecto.SQL.Sandbox)
      end

      socket("/live", Phoenix.LiveView.Socket,
        websocket: [
          connect_info: [
            :user_agent,
            session: EndpointTemplate.session_options()
          ]
        ]
      )

      if module_enabled?(Bonfire.API.GraphQL.UserSocket) do
        socket("/api/socket", Bonfire.API.GraphQL.UserSocket,
          websocket: true,
          longpoll: false
        )
      end

      # Serve at "/" the static files from "priv/static" directory.
      #
      # You should set gzip to true if you are running phx.digest
      # when deploying your static files in production.

      plug(Plug.Static,
        at: "/",
        from: :bonfire,
        gzip: true,
        only:
          ~w(public assets css fonts images js favicon.ico pwa pwabuilder-sw.js robots.txt cache_manifest.json source.tar.gz index.html)
      )

      plug(Plug.Static,
        at: "/data/uploads/",
        from: "data/uploads",
        gzip: true
      )

      plug(Plug.Static,
        at: "/",
        from: :livebook,
        gzip: true,
        only: ~w(images js)
      )

      plug(Plug.Static,
        at: "/livebook/",
        from: :livebook,
        gzip: true,
        only: ~w(css images js favicon.ico robots.txt cache_manifest.json)
      )

      plug(Phoenix.LiveDashboard.RequestLogger,
        param_key: "request_logger",
        cookie_key: "request_logger"
      )

      plug(Plug.RequestId)
      plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

      plug(Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Phoenix.json_library()
      )

      plug(Bonfire.ErrorReporting)

      plug(Plug.MethodOverride)
      plug(Plug.Head)
      plug(Plug.Session, EndpointTemplate.session_options())
    end
  end

  def session_options do
    # TODO: check that this is changeable at runtime
    # The session will be stored in the cookie and signed,
    # this means its contents can be read but not tampered with.
    # Set :encryption_salt if you would also like to encrypt it.
    [
      store: :cookie,
      key: "_bonfire_key",
      signing_salt: Config.get!(:signing_salt),
      encryption_salt: Config.get!(:encryption_salt),
      # 60 days by default
      max_age: Config.get(:session_time_to_remember, 60 * 60 * 24 * 60)
    ]
  end
end
