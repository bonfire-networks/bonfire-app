if System.get_env("AS_DESKTOP_APP") in ["1", "true"] do
  defmodule Bonfire.Desktop.Endpoint do
    use Desktop.Endpoint, otp_app: :bonfire
    use Bonfire.UI.Common.EndpointTemplate

    use Bonfire.UI.Common.Endpoint.LiveReload, code_reloading?

    plug(Bonfire.Web.Router)
  end
end
