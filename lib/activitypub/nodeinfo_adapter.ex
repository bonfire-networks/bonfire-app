defmodule Bonfire.NodeinfoAdapter do
  @behaviour Nodeinfo.Adapter

  def base_url() do
    Bonfire.Web.Endpoint.url()
  end

  def gather_nodeinfo_data() do
    %{
      app_name: "Bonfire",
      app_version: "0.1.0",
      open_registrations: false,
      user_count: "unknown",
      node_name: "Bonfire",
      node_description: "An instance of Bonfire",
      federating: true,
      repository: "https://github.com/bonfire-ecosystem/bonfire-app"
    }
  end
end
