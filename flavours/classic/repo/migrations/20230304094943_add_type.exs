defmodule Bonfire.Repo.Migrations.ClassifyAddType  do
  @moduledoc false
  use Ecto.Migration

  def up do
    if Code.ensure_loaded?(Bonfire.Classify.Migrations) do
      Bonfire.Classify.Migrations.add_type()
    end
  end

  def down do
    # TODO
  end
end
