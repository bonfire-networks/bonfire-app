defmodule Bonfire.Repo.Migrations.ImportApActivity do
  @moduledoc false
  use Ecto.Migration
  import Bonfire.Data.Social.APActivity.Migration

  def up(), do: migrate_apactivity()
  def down(), do: migrate_apactivity()
end
