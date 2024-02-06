defmodule Bonfire.Repo.Migrations.AddFiles do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Files.Media.Migrations
  import Needle.Migration

  def up do
    Bonfire.Files.Media.Migrations.migrate_media()
  end

  def down do
    Bonfire.Files.Media.Migrations.migrate_media()
  end
end
