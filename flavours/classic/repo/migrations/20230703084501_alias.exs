defmodule Bonfire.Repo.Migrations.Alias do
  @moduledoc false
  use Ecto.Migration
  require Bonfire.Data.Identity.Alias.Migration

  def up do
    Bonfire.Data.Identity.Alias.Migration.migrate_alias()
  end

  def down do
    Bonfire.Data.Identity.Alias.Migration.migrate_alias()
  end
end
