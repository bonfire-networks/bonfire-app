defmodule ActivityPub.Repo.Migrations.AddObjectBoolean do
  @moduledoc false
  use Ecto.Migration

  def up do
    ActivityPub.Migrations.add_object_boolean()
  end

  def down do
    ActivityPub.Migrations.drop_object_boolean()
  end
end
