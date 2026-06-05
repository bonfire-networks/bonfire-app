import Config

# Our fork of decent with keychain support — precompiled binaries at bonfire-networks/decent
config :decent,
  github_url: System.get_env("DECENT_GITHUB_URL", "https://github.com/bonfire-networks/decent")

# Force local Rust build when DECENT_BUILD=1
# (set this when using forks/decent locally or in Docker builds)
if System.get_env("DECENT_BUILD") in ["1", "true"] do
  config :rustler_precompiled, :force_build, decent: true
end

config :bonfire_mailer,
  check_mx: true,
  check_format: true
