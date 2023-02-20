defmodule Bonfire.Repo.Migrations.Pin do
  @moduledoc false
  use Ecto.Migration
  require Bonfire.Data.Social.Pin.Migration

  def up do
    Bonfire.Data.Social.Pin.Migration.migrate_pin()
  end

  def down do
    Bonfire.Data.Social.Pin.Migration.migrate_pin()
  end
end
