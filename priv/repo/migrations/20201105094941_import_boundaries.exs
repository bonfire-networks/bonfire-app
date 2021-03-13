defmodule Bonfire.Boundaries.Repo.Migrations.ImportBoundaries do
  use Ecto.Migration

  import Bonfire.Boundaries.Migrations
  # accounts & users

  def change, do: migrate_boundaries

end
