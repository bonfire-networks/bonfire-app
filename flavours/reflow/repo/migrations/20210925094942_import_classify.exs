defmodule Bonfire.Repo.Migrations.ImportClassify do
  use Ecto.Migration

  def up do
    Bonfire.Classify.Migrations.up
  end

  def down do
    Bonfire.Classify.Migrations.down
  end
end
