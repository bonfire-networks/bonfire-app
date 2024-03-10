import Config

if System.get_env("WITH_API_GRAPHQL") != "yes" do
  config :bonfire_api_graphql,
    modularity: :disabled
end

config :bonfire_social, Bonfire.Social.Pins, modularity: :disabled

config :bonfire, :ui,
  default_nav_extensions: [
    :bonfire,
    :bonfire_ui_common,
    :bonfire_ui_social,
    :bonfire_ui_reactions,
    :bonfire_ui_messages,
    :bonfire_open_science,
    :bonfire_files
    # :bonfire_ui_search
  ]
