defmodule Bonfire.Repo.Migrations.Hashtag do
  @moduledoc false
  use Ecto.Migration
  require Bonfire.Tag.Hashtag.Migration

  def up do
    Bonfire.Tag.Hashtag.Migration.migrate_hashtag()
  end

  def down do
    Bonfire.Tag.Hashtag.Migration.migrate_hashtag()
  end
end
