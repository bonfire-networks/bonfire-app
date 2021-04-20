defmodule Bonfire.Repo.Migrations.ImportGeolocation do
  use Ecto.Migration

  def up do
    if Code.ensure_loaded?(Bonfire.Geolocate.Migrations) do
       Bonfire.Geolocate.Migrations.change
    end
  end

  def down do
    if Code.ensure_loaded?(Bonfire.Geolocate.Migrations) do
       Bonfire.Geolocate.Migrations.change
    end
  end
end
