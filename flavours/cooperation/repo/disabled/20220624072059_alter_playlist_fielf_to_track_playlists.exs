defmodule Rauversion.Repo.Migrations.AlterPlaylistFielfToTrackPlaylists do
  @moduledoc false
  use Ecto.Migration

  def change do
    rename(table("track_playlists"), :playlist, to: :playlist_id)
  end
end
