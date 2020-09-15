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
    # guest visible pages
    live "/", IndexLive, :index
    resources "/signup", SignupController, only: [:index, :create]
    resources "/confirm-email", ConfirmEmailController, only: [:index, :show, :create]
    resources "/login", LoginController, only: [:index, :create]
    live "/password/forgot", ResetPasswordLive, :reset_password
    live "/password/change", ChangePasswordLive, :change_password
    live "/password/change/:token", ChangePasswordLive, :change_password_confirm
    # authenticated pages
    live "/create-user", CreateUserLive, :create_user
    get "/switch-user", SwitchUserController, :index
    get "/switch-user/@:username", SwitchUserController, :show

    live "/home", HomeLive, :home
    live "/home/@:username", HomeLive, :home_user
    live "/@:username", ProfileLive
    live "/@:username/:tab", ProfileLive
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
