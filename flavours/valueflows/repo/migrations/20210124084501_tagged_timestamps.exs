defmodule Bonfire.Repo.Migrations.TaggedTimestamps do
  use Ecto.Migration

  def up do
    Bonfire.Tag.Migrations.tagged_timestamps_up()
  end

  def down do
    Bonfire.Tag.Migrations.tagged_timestamps_down()
  end
end
