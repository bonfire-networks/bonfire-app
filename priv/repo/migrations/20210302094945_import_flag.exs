defmodule Bonfire.Repo.Migrations.ImportFlag do
  use Ecto.Migration

  import Bonfire.Data.Social.Flag.Migration
  import Bonfire.Data.Social.FlagCount.Migration

  def up do
    migrate_flag()
    migrate_flag_count()
  end

  def down do
    migrate_flag_count()
    migrate_flag()
  end

end
