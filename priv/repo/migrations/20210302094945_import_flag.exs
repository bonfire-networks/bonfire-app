defmodule Bonfire.Repo.Migrations.ImportFlag do
  use Ecto.Migration

  import Bonfire.Data.Social.Flag.Migration
  import Bonfire.Data.Social.FlagCount.Migration

  def change do
    migrate_flag()
    migrate_flag_count()
  end

end
