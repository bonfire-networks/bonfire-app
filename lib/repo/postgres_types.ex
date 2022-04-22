# required by Bonfire.Geolocate
Postgrex.Types.define(
  Bonfire.PostgresTypes,
  Ecto.Adapters.Postgres.extensions(),
  json: Jason
)

Postgrex.Types.define(
  Bonfire.Geolocate.PostgresTypes,
  Ecto.Adapters.Postgres.extensions() ++ (if Code.ensure_loaded?(Geo.PostGIS.Extension), do: [Geo.PostGIS.Extension], else: []),
  json: Jason
)
