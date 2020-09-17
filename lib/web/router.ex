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
    resources "/password/forgot", ForgotPasswordController, only: [:index, :create]
    resources "/password/reset/:token", ResetPasswordController, only: [:index, :create]
    resources "/password/change", ChangePasswordController, only: [:index, :create]
    # authenticated pages
    resources "/create-user", CreateUserController, only: [:index, :create]
    get "/switch-user", SwitchUserController, :index
    get "/switch-user/@:username", SwitchUserController, :show

    live "/home", HomeLive, :home
    live "/home/@:username", HomeLive, :home_user
    live "/@:username", ProfileLive, :profile
    live "/@:username/:tab", ProfileLive, :profile_tab
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
