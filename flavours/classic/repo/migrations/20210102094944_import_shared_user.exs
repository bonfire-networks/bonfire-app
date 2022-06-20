defmodule Bonfire.Repo.Migrations.ImportSharedUser do
  use Ecto.Migration

  import Bonfire.Data.SharedUser.Migration
  # accounts & users

  def up, do: migrate_shared_user()
  def down, do: migrate_shared_user()

end
