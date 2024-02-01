defmodule Bonfire.Repo.Migrations.ClassifyAddTree  do
  @moduledoc false
  use Ecto.Migration
  require Bonfire.Classify.Tree.Migration

  def up do
    if Code.ensure_loaded?(Bonfire.Classify.Tree.Migration) do
      Bonfire.Classify.Tree.Migration.migrate_tree()
      Bonfire.Classify.Tree.Migration.migrate_functions()
    end
  end

  def down do
    if Code.ensure_loaded?(Bonfire.Classify.Tree.Migration) do
      Bonfire.Classify.Tree.Migration.migrate_functions()
      Bonfire.Classify.Tree.Migration.migrate_tree()
    end
  end
end
