defmodule CommonsPub.Me.Web.SettingsLive.SettingsNavigationLive do
  use CommonsPub.Me.UseModule, [:web_module, :live_component]

  def render(assigns) do
    ~L"""
    <%= live_patch link_body("My profile", "feather-user"),
      to: "/settings/general",
      class: if @selected == "general", do: "navigation__item active", else: "navigation__item"
    %>

    """
  end

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
