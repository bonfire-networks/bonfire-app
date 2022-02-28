import Config

config :bonfire_me,
  templates_path: "lib"

config :bonfire_me, Bonfire.Me.Identity.Mails,
  confirm_email:  [subject: "Confirm your email - Bonfire"],
  forgot_password: [subject: "Reset your password - Bonfire"]

#### Pointer class configuration

config :bonfire_me, Bonfire.Me.Follows,
  followable_types: [Bonfire.Data.Identity.User]

config :bonfire_me, Bonfire.Me.Accounts,
  epics: [
    delete: [
    ],
  ]
