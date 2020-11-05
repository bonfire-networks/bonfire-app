defmodule CommonsPub.Me.Web.HeroProfileLive do
  use CommonsPub.Me.UseModule, [:web_module, :live_component]


  def render(assigns) do
    ~L"""
      <div class="mainContent__hero">
        <div class="hero__image">
          <img alt="background image" src="<%= e(@user, :profile, :image_url, "") %>" />
        </div>
        <div class="hero__info">
          <div class="info__icon">
            <img alt="profile pic" src="<%= e(@user, :profile, :icon_url, "") %>" />
          </div>
          <div class="info__meta">
            <h1><%= e(@user, :profile, :name, "Me")  %></h1>
            <h4 class="info__username"><%= e(@user, :character, :username, "me") %></h4>
            <div class="info__details">
            <%= if e(@user, :profile, :website, nil) do %>
              <div class="details__meta">
                <a href="#" target="_blank">
                  <i class="feather-external-link"></i>
                  <%= e(@user, :profile, :website, "") %>
                </a>
              </div>
              <% end %>
              <%= if e(@user, :profile, :location, nil) do %>
                <div class="details__meta">
                  <i class="feather-map-pin"></i><%= e(@user, :profile, :location, "") %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
