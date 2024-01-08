defmodule Bonfire.Messages.Repo.Migrations.ImportSocial do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Messages.Migrations
  import Needle.Migration

  def up do
    migrate_social()
  end

  def down, do: migrate_social()
end
