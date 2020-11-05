defmodule CommonsPub.Me.Web.Router do
  defmacro __using__(_) do

    quote do

      scope "/", CommonsPub.Me.Web do
        pipe_through :browser
        # guest visible pages
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
        get "/logout", LogoutController, :index

        live "/profile", ProfileLive, :profile
        live "/@:username", ProfileLive, :profile
        live "/@:username/:tab", ProfileLive, :profile_tab
        live "/settings", SettingsLive, :setting
        live "/settings/:tab", SettingsLive, :setting_tav
      end

    end
  end
end
