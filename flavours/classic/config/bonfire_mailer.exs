import Config

config :bonfire_mailer,
  check_mx: true,
  check_format: true

config :bonfire, Bonfire.Mailer,
  # what service you want to use to send emails, from these: https://github.com/thoughtbot/bamboo#available-adapters
  # we recommend leaving LocalAdapter (which is just a fallback which won't actually send emails) and setting the actual adapter in runtime.exs
  adapter: Bamboo.LocalAdapter
