import Config

config :bonfire_me,
  web_module: Bonfire.Web,
  repo_module: Bonfire.Repo,
  mailer_module: Bonfire.Mailer,
  helper_module: Bonfire.Common.Utils,
  templates_path: "lib"

alias Bonfire.Me.Identity

config :bonfire_me, Identity.Emails,
  confirm_email: [subject: "Confirm your email - Bonfire"],
  reset_password: [subject: "Reset your password - Bonfire"]

#### Pointer class configuration

alias Bonfire.Data.Identity.User

config :bonfire_me, Bonfire.Me.Users.Follows,
  followable_types: [User]

