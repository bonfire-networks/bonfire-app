defmodule Bonfire.Social.Repo.Migrations.CountFunctions do
  use Ecto.Migration

  import Bonfire.Data.Social.FollowCount.Migration
  import Bonfire.Data.Social.BoostCount.Migration
  import Bonfire.Data.Social.LikeCount.Migration
  import Bonfire.Data.Social.Replied.Migration

  def change do
    Bonfire.Data.Social.FollowCount.Migration.migrate_functions()
    Bonfire.Data.Social.BoostCount.Migration.migrate_functions()
    Bonfire.Data.Social.LikeCount.Migration.migrate_functions()

    Bonfire.Data.Social.Replied.Migration.add_count_fields()
    # flush()
    Bonfire.Data.Social.Replied.Migration.migrate_functions()
  end

end
