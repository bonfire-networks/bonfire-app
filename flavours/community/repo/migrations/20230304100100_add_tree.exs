defmodule Bonfire.Repo.Migrations.ClassifyAddTree do
  @moduledoc false
  use Ecto.Migration
  require Bonfire.Classify.Tree.Migration

  def up do
    Bonfire.Classify.Tree.Migration.migrate_tree()
    Bonfire.Classify.Tree.Migration.migrate_functions()
  end

  def down do
    Bonfire.Classify.Tree.Migration.migrate_functions()
    Bonfire.Classify.Tree.Migration.migrate_tree()
  end
end
