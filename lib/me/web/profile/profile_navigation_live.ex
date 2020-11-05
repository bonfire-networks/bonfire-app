defmodule CommonsPub.Me.Web.ProfileNavigationLive do
  use CommonsPub.Me.UseModule, [:web_module, :live_component]

  def render(assigns) do
    ~L"""
    <%= live_patch link_body("About", "feather-book-open"),
      to: "/@" <> @username <> "/about",
      class: if @selected == "about", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("Posts", "feather-message-square"),
      to: "/@" <> @username <> "/posts",
      class: if @selected == "posts", do: "navigation__item active", else: "navigation__item"
      %>
    <%= live_patch link_body("Favorites", "feather-star"),
      to: "/@" <> @username <> "/likes",
      class: if @selected == "likes", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("Following", "feather-eye"),
      to: "/@" <> @username <> "/following",
      class: if @selected == "following", do: "navigation__item active", else: "navigation__item"
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
