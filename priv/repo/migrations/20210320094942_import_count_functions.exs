defmodule Bonfire.Social.Repo.Migrations.ImportCountFunctions do
  use Ecto.Migration

  import Bonfire.Data.Social.FollowCount.Migration

  def change do
    Bonfire.Data.Social.FollowCount.Migration.migrate_functions()
  end

end
