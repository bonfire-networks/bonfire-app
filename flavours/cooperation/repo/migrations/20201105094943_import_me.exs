defmodule Bonfire.Breadpub.Repo.Migrations.ImportMe do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Breadpub.Migration
  # accounts & users

  def change, do: migrate_me
end
