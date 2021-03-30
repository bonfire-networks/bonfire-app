defmodule Bonfire.Social.Repo.Migrations.CountFunctions do
  use Ecto.Migration

  import Bonfire.Data.Social.FollowCount.Migration
  import Bonfire.Data.Social.BoostCount.Migration
  import Bonfire.Data.Social.LikeCount.Migration

  def change do
    Bonfire.Data.Social.FollowCount.Migration.migrate_functions()
    Bonfire.Data.Social.BoostCount.Migration.migrate_functions()
    Bonfire.Data.Social.LikeCount.Migration.migrate_functions()
  end

end
