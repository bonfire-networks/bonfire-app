use Mix.Config

config :cpub_me, :web_module, CommonsPub.WebPhoenix
config :cpub_me, :repo_module, VoxPublica.Repo
config :cpub_me, :mailer_module, VoxPublica.Mailer
config :cpub_me, :helper_module, CommonsPub.WebPhoenixHelpers
config :cpub_me, :templates_path, "lib"

alias CommonsPub.Me.Accounts

config :cpub_me, Accounts.Emails,
  confirm_email: [subject: "Confirm your email - VoxPublica"],
  reset_password: [subject: "Reset your password - VoxPublica"]

#### Forms configuration

# You probably will want to leave these

alias CommonsPub.Me.Accounts.{
  ChangePasswordFields,
  ConfirmEmailFields,
  LoginFields,
  ResetPasswordFields,
  SignupFields,
}

# these are not used yet, but they will be

config :cpub_me, ChangePasswordFields,
  cast: [:old_password, :password, :password_confirmation],
  required: [:old_password, :password, :password_confirmation],
  confirm: :password,
  new_password: [length: [min: 10, max: 64]]

config :cpub_me, ConfirmEmailFields,
  cast: [:email],
  required: [:email],
  email: [format: ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$)]

config :cpub_me, LoginFields,
  cast: [:email, :password],
  required: [:email, :password],
  email: [format: ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$)],
  password: [length: [min: 10, max: 64]]

config :cpub_me, ResetPasswordFields,
  cast: [:password, :password_confirmation],
  required: [:password, :password_confirmation],
  confirm: :password,
  password: [length: [min: 10, max: 64]]

config :cpub_me, SignupFields,
  cast: [:email, :password],
  required: [:email, :password],
  email: [format: ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$)],
  password: [length: [min: 10, max: 64]]

alias CommonsPub.Me.Users.ValidFields

config :cpub_me, ValidFields,
  username: [format: ~r(^[a-z][a-z0-9_]{2,30}$)i],
  name: [length: [min: 3, max: 50]],
  summary: [length: [min: 20, max: 500]]
