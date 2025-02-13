defmodule Bonfire.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :bonfire
  use Bonfire.UI.Common.EndpointTemplate

  use Bonfire.UI.Common.Endpoint.LiveReload, code_reloading?

  # NOTE: putting it here (after Plug.Static which is EndpointTemplate) means it does not apply to static assets
  plug Bonfire.Web.Router.CORS

  # NOTE: can use the following to time the router
  # @decorate time()
  # defp router(conn, _), do: Bonfire.Web.Router.call(conn, [])
  # plug :router
  plug(Bonfire.Web.Router)
end
