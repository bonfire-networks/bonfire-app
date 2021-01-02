defmodule Bonfire.Repo.Migrations.ImportSharedUser do
  use Ecto.Migration

  import Bonfire.Data.SharedUser.Migration
  # accounts & users

  def change, do: migrate_shared_user()

end
