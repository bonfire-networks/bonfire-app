defmodule Bonfire.Web.Endpoint do
  use Bonfire.Web.EndpointTemplate
  alias Bonfire.Common.Utils

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

    font_family = Bonfire.Me.Settings.get([:ui, :font_family], "Inter", conn) |> Utils.maybe_to_string() |> String.downcase()

    """
    <link phx-track-static rel='stylesheet' href='#{static_path("/assets/bonfire_basic.css")}'/>

     <link phx-track-static rel='stylesheet' href='#{static_path("/fonts/#{font_family}.css")}'/>

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
