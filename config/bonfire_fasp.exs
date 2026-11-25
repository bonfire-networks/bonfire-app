import Config

#### Extension-specific compile-time configuration goes here, everything else should be in `Bonfire.Fasp.RuntimeConfig`

config :fasp_ex,
  adapter: Bonfire.Fasp.Adapter,
  # nil: the adapter of `config :tesla, :adapter`, the one `Bonfire.Common.HTTP` uses (Finch, or `Tesla.Mock` in tests)
  tesla_adapter: nil,
  # the same telemetry and SSRF protection as `Bonfire.Common.HTTP.Connection`: FASP base URLs come from admins and remote servers
  tesla_middleware: [Tesla.Middleware.Telemetry, Bonfire.Common.HTTP.SSRF]

config :bonfire_fasp,
  # who may register with us as their FASP, once the provider is enabled (an instance setting, so an admin can change it): `:closed` (nobody new), `:allowlist` (servers in the instance-wide allow-list) or `:open` (anyone)
  provider_registration: :closed,
  # offer the debug `callback` capability as a FASP (a dev and test aid, see `Bonfire.Fasp.DebugCallback`): off in production
  debug_callback_enabled: config_env() != :prod,
  # how many calls the debug callback log keeps per role, in memory
  debug_callback_log_size: 100

# the provider role (acting as a FASP for other instances) is off until an admin picks one of the other cards on "Services we provide" (or enables the module in the extensions settings); the client role is not affected. The page itself stays reachable for admins.
config :bonfire_fasp, Bonfire.Fasp.Provider, modularity: :disabled
