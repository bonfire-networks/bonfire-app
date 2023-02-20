defmodule Rauversion.Repo.Migrations.AddStateToTrack do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:tracks) do
      add(:state, :string)
    end

    create(index(:tracks, [:state]))
  end
end
