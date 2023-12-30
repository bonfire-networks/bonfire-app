defmodule Bonfire.Posts.Repo.Migrations.ImportSocial do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Posts.Migrations
  import Pointers.Migration

  def up do
    migrate_social()
  end

  def down, do: migrate_social()
end
