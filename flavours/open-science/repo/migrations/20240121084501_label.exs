defmodule Bonfire.Repo.Migrations.Label do
  @moduledoc false
  use Ecto.Migration
  require Bonfire.Label.Migration

  def up do
    Bonfire.Label.Migration.migrate_label()
  end

  def down do
    Bonfire.Label.Migration.migrate_label()
  end
end
