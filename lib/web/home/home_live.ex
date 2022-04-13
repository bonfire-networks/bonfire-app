defmodule Bonfire.Web.HomeLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.Web, {:surface_view, [layout: {Bonfire.UI.Social.Web.LayoutView, "without_sidebar.html"}]}
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Common.Utils

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf, LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(_params, _session, socket) do
    instance_name = Bonfire.Common.Config.get([:ui, :theme, :instance_name], l "An instance of Bonfire")
    links = Bonfire.Common.Config.get([:ui, :theme, :instance_welcome, :links], %{
      "https://bonfirenetworks.org/"=> l("About Bonfire"),
      "https://bonfirenetworks.org/contribute/"=> l("Contribute")
    })
    welcome_title = Bonfire.Common.Config.get([:ui, :theme, :instance_welcome, :title], l "About")
    welcome_text = (
      Bonfire.Common.Config.get([:ui, :theme, :instance_welcome, :description], nil)
      || Bonfire.Common.Config.get([:ui, :theme, :instance_description], l "Welcome")
      ) |> Utils.md
    {:ok, socket
    |> assign(
      page_title: instance_name,
      welcome_title: welcome_title,
      welcome: welcome_text,
      links: links
    )}
  end


  defdelegate handle_params(params, attrs, socket), to: Bonfire.Common.LiveHandlers
  def handle_event(action, attrs, socket), do: Bonfire.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

end
