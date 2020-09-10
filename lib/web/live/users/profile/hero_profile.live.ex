defmodule VoxPublica.Web.HeroProfileLive do
  use VoxPublica.Web, :live_component


  def render(assigns) do
    ~L"""
      <div class="mainContent__hero">
        <div class="hero__image">
          <img alt="background image" src="<%= @user.image_url %>" />
        </div>
        <div class="hero__info">
          <div class="info__icon">
            <img alt="profile pic" src="<%= @user.icon_url %>" />
          </div>
          <div class="info__meta">
            <h1><%= @user.name %></h1>
            <h4 class="info__username"><%= @user.username %></h4>
            <div class="info__details">
            <%= if @user.website do %>
              <div class="details__meta">
                <a href="#" target="_blank">
                  <i class="feather-external-link"></i>
                  <%= @user.website %>
                </a>
              </div>
              <% end %>
              <%= if @user.location do %>
                <div class="details__meta">
                  <i class="feather-map-pin"></i><%= @user.location %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
