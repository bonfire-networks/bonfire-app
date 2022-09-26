defmodule Rauversion.Repo.Migrations.AddCounterCachesToTrack do
  use Ecto.Migration

  def change do
    alter table(:tracks) do
      add(:likes_count, :integer, default: 0)
      add(:reposts_count, :integer, default: 0)
    end
  end
end
