defmodule Bonfire.Data.Identity.Repo.Migrations.SettingsJson do
  @moduledoc false
  use Ecto.Migration

  import Needle.Migration

  def up do
    alter table("bonfire_data_identity_settings") do
      Ecto.Migration.add_if_not_exists(:json, :jsonb)
    end
  end

  def down, do: nil
end
