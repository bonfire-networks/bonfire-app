defmodule Bonfire.Repo.Migrations.Hashtag do
  use Ecto.Migration

  def up do
    Bonfire.Tag.Migrations.migrate_hashtag()
  end

  def down do
    Bonfire.Tag.Migrations.migrate_hashtag()
  end
end
