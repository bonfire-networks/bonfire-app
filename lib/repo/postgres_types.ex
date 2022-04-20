# required by Bonfire.Geolocate
Postgrex.Types.define(
  Bonfire.PostgresTypes,
  Ecto.Adapters.Postgres.extensions(),
  json: Jason
)

Postgrex.Types.define(
  Bonfire.Geolocate.PostgresTypes,
  # [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  Ecto.Adapters.Postgres.extensions(),
  json: Jason
)
