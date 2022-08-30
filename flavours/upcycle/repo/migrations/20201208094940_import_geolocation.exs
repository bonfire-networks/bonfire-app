defmodule Bonfire.Repo.Migrations.ImportGeolocation do
  use Ecto.Migration

  def up do
    Bonfire.Geolocate.Migrations.change
  end

  def down do
    Bonfire.Geolocate.Migrations.change
  end
end
