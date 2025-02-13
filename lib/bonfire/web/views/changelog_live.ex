defmodule Bonfire.Web.Views.ChangelogLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  @changelog File.read("#{Config.get(:project_path, "../..")}/docs/CHANGELOG.md")

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    # app = String.capitalize(Bonfire.Application.name())
    # instance_name = Config.get([:ui, :theme, :instance_name], app)

    links =
      Config.get([:ui, :theme, :instance_welcome, :links], %{
        l("About Bonfire") => "https://bonfirenetworks.org/",
        l("Contribute") => "https://bonfirenetworks.org/contribute/"
      })

    changelog =
      case @changelog do
        {:ok, changelog} -> changelog
        _ -> nil
      end

    {:ok,
     socket
     |> assign(
       page: "Changelog",
       page_title: l("Changelog"),
       links: links,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(),
       changelog: changelog,
       without_sidebar: false
     )}
  end
end
