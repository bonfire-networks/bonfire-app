defmodule Bonfire.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :bonfire
  use Bonfire.UI.Common.EndpointTemplate
  alias Bonfire.Common.Utils
  alias Bonfire.Common.Config

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)

    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :bonfire)

    # plug(PhoenixProfiler)
  end

  plug(Bonfire.Web.Router)

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

    font_family =
      Bonfire.Me.Settings.get([:ui, :font_family], "Inter (Latin Languages)", conn)
      |> Utils.maybe_to_string()
      |> String.trim_trailing(" Languages)")
      |> String.replace([" ", "-", "(", ")"], "-")
      |> String.replace("--", "-")
      |> String.downcase()

    """
    <link rel="icon" type="image/x-icon" href="/favicon.ico">

    <link phx-track-static rel='stylesheet' href='#{static_path("/assets/bonfire_basic.css")}'/>
    <link phx-track-static rel='stylesheet' href='#{static_path("/fonts/#{font_family}.css")}'/>

    <link rel="manifest" href="/pwa/manifest.json" />
    <script type="module">
      import 'https://cdn.jsdelivr.net/npm/@pwabuilder/pwaupdate';
      const el = document.createElement('pwa-update');
      document.body.appendChild(el);
    </script>
    """
  end

  def include_assets(conn, :bottom) do
    js =
      if Utils.e(conn, :assigns, :current_account, nil) ||
           Utils.e(conn, :assigns, :current_user, nil) do
        static_path("/assets/bonfire_live.js")
      else
        static_path("/assets/bonfire_basic.js")
      end

    """
    #{PhoenixGon.View.render_gon_script(conn) |> Phoenix.HTML.safe_to_string()}
    <script defer phx-track-static crossorigin='anonymous' src='#{js}'></script>
    """
  end

  def reload!(), do: Phoenix.CodeReloader.reload!(__MODULE__)

  def generate_reverse_router!() do
    Code.eval_file(Path.join(:code.priv_dir(:bonfire), "extras/router_reverse.ex"))
  end
end
