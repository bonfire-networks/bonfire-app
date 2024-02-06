defmodule Bonfire.Repo.Migrations.Sensitive do
  @moduledoc false
  use Ecto.Migration
  require Bonfire.Data.Social.Sensitive.Migration

  def up do
    Bonfire.Data.Social.Sensitive.Migration.migrate_sensitive()
  end

  def down do
    Bonfire.Data.Social.Sensitive.Migration.migrate_sensitive()
  end
end
