defmodule Bonfire.Boundaries.Repo.Migrations.ImportBoundaries do
  use Ecto.Migration

  import Bonfire.Boundaries.Migrations

  def change, do: migrate_boundaries()

end
