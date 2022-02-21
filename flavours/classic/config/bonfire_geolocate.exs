import Config

config :bonfire_geolocate,
  templates_path: "lib"

config :bonfire, :js_config,
  mapbox_api_key: System.get_env("MAPBOX_API_KEY")

# add references of tagged objects to any Geolocation
config :bonfire_geolocate, Bonfire.Geolocate.Geolocation,
  [code: quote do
    # has_many :controlled, unquote(Controlled), foreign_key: :id, references: :id
    many_to_many :tags, unquote(Pointer),
      join_through: unquote(Tagged),
      unique: true,
      join_keys: [id: :id, tag_id: :id],
      on_replace: :delete
  end]
