use Mix.Config

config :bonfire_me, :web_module, Bonfire.WebPhoenix
config :bonfire_me, :repo_module, Bonfire.Repo
config :bonfire_me, :mailer_module, Bonfire.Mailer
config :bonfire_me, :helper_module, Bonfire.WebPhoenixHelpers
config :bonfire_me, :templates_path, "lib"

alias Bonfire.Me.Accounts

config :bonfire_me, Accounts.Emails,
  confirm_email: [subject: "Confirm your email - Bonfire"],
  reset_password: [subject: "Reset your password - Bonfire"]

#### Forms configuration

# You probably will want to leave these

alias Bonfire.Me.Accounts.{
  ChangePasswordFields,
  ConfirmEmailFields,
  LoginFields,
  ResetPasswordFields,
  SignupFields,
}

# these are not used yet, but they will be

config :bonfire_me, ChangePasswordFields,
  cast: [:old_password, :password, :password_confirmation],
  required: [:old_password, :password, :password_confirmation],
  confirm: :password,
  new_password: [length: [min: 10, max: 64]]

config :bonfire_me, ConfirmEmailFields,
  cast: [:email],
  required: [:email],
  email: [format: ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$)]

config :bonfire_me, LoginFields,
  cast: [:email, :password],
  required: [:email, :password],
  email: [format: ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$)],
  password: [length: [min: 10, max: 64]]

config :bonfire_me, ResetPasswordFields,
  cast: [:password, :password_confirmation],
  required: [:password, :password_confirmation],
  confirm: :password,
  password: [length: [min: 10, max: 64]]

config :bonfire_me, SignupFields,
  cast: [:email, :password],
  required: [:email, :password],
  email: [format: ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$)],
  password: [length: [min: 10, max: 64]]

alias Bonfire.Me.Users.ValidFields

config :bonfire_me, ValidFields,
  username: [format: ~r(^[a-z][a-z0-9_]{2,30}$)i],
  name: [length: [min: 3, max: 50]],
  summary: [length: [min: 20, max: 500]]
