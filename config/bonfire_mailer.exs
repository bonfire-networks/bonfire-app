import Config

config :bonfire_mailer,
  otp_app: :bonfire,
  from_address: "noreply@bonfire.local",
  check_mx: true,
  check_format: true
