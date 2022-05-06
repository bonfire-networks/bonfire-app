defmodule Bonfire.Repo.Migrations.ImportFlag do
  use Ecto.Migration

  import Bonfire.Data.Social.Flag.Migration

  def up do
    migrate_flag()
  end

  def down do
    migrate_flag()
  end

end
