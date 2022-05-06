defmodule Bonfire.Repo.Migrations.ImportBoost do
  use Ecto.Migration

  import Bonfire.Data.Social.Boost.Migration

  def up do
    migrate_boost()
  end
  def down do
    migrate_boost()
  end

end
