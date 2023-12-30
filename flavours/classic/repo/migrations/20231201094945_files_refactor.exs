defmodule Bonfire.Files.Repo.Migrations.FilesRefactor do
  @moduledoc false
  use Ecto.Migration

  import Needle.Migration

  def up do
    alter table("bonfire_files_media") do
      Ecto.Migration.add_if_not_exists(:file, :jsonb)
    end
  end

  def down, do: nil
end
