defmodule Bonfire.Web.EndpointTemplate do
defmacro __using__(_) do
quote do
  use Bonfire.ErrorReporting # make sure this comes before the Phoenix endpoint
  use Phoenix.Endpoint, otp_app: :bonfire

  import Bonfire.Common.Extend
  alias Bonfire.Common.Utils
  alias Bonfire.Common.Config

  use_if_enabled Absinthe.Phoenix.Endpoint

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_bonfire_key",
    signing_salt: Config.get!(:signing_salt),
    encryption_salt: Config.get!(:encryption_salt)
  ]

  if Application.get_env(:bonfire, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [:user_agent, session: @session_options]]

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
  plug Plug.Session, @session_options

  plug Bonfire.Web.Router

  def include_assets(conn) do
    include_assets(conn, :top)
    include_assets(conn, :bottom)
  end

  def include_assets(conn, :top) do

    # unused?
    # <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/choices.js/public/assets/styles/choices.min.css" />
    # <script src="https://cdn.jsdelivr.net/npm/choices.js/public/assets/scripts/choices.min.js"></script>

    # imported into main CSS already
    # <link href="https://unpkg.com/@yaireo/tagify/dist/tagify.css" rel="stylesheet" type="text/css" />

    # TODO: serve fonts directly
    """
    <link phx-track-static rel='stylesheet' href='#{static_path("/assets/bonfire_basic.css")}'/>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@100;300;400;700;900&display=swap" rel="stylesheet">

    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    """
  end

  def include_assets(conn, :bottom) do
    js = if Utils.e(conn, :assigns, :current_account, nil) || Utils.e(conn, :assigns, :current_user, nil) do
      static_path("/assets/bonfire_live.js")
    else
      static_path("/assets/bonfire_basic.js")
    end

    (PhoenixGon.View.render_gon_script(conn) |> Phoenix.HTML.safe_to_string) <>
    """
    <script defer phx-track-static crossorigin='anonymous' src='#{js}'></script>
    """
  end

end
end
end
