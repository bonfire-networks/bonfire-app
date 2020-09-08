defmodule VoxPublica.Web.Router do
  use VoxPublica.Web, :router
  use ActivityPubWeb.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {VoxPublica.Web.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", VoxPublica.Web do
    pipe_through :browser
    live "/", IndexLive, :index
    live "/register", RegisterLive, :register
    live "/login", LoginLive, :login
    # get "/confirm-email/:token", ConfirmEmailController, :confirm_email
    # live "/reset-password", ResetPasswordLive, :reset_password
    # live "/reset-password/:token", ResetPasswordLive, :reset_password_confirm
    # live "/home", HomeLive, :homellow only admins to access it.
  end

  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: VoxPublica.Web.Telemetry
    end
  end
end
