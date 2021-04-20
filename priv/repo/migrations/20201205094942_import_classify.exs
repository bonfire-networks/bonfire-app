defmodule Bonfire.Repo.Migrations.ImportClassify do
  use Ecto.Migration

  def up do
    if Code.ensure_loaded?(Bonfire.Classify.Migrations) do
       Bonfire.Classify.Migrations.up
    end
  end

  def down do
    if Code.ensure_loaded?(Bonfire.Classify.Migrations) do
       Bonfire.Classify.Migrations.down
    end
  end
end
