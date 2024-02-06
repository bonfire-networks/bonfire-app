defmodule Bonfire.Repo.Migrations.ClassifyAddType do
  @moduledoc false
  use Ecto.Migration

  def up do
    Bonfire.Classify.Migrations.add_type()
  end

  def down do
    # TODO
  end
end
