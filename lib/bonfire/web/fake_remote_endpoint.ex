defmodule Bonfire.Web.FakeRemoteEndpoint do
  use Phoenix.Endpoint, otp_app: :bonfire
  use Bonfire.UI.Common.EndpointTemplate

  plug(Bonfire.Web.Router)
end
