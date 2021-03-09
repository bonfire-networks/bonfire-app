defmodule Bonfire.Repo.Migrations.ImportBoost do
  use Ecto.Migration

  import Bonfire.Data.Social.Boost.Migration
  import Bonfire.Data.Social.BoostCount.Migration

  def change do
    migrate_boost()
    migrate_boost_count()
  end

end
