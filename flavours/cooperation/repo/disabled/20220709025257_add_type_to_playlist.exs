defmodule Rauversion.Repo.Migrations.AddTypeToPlaylist do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:playlists) do
      add(:playlist_type, :string)
      add(:genre, :string)
      add(:release_date, :utc_datetime)
    end
  end
end
