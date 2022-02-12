defmodule ActivityPub.Repo.Migrations.APTestTable do
  use Ecto.Migration

  def change do
    # This table only exists for test purposes
    create table("local_actor", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :username, :citext
      add :data, :map
      add :local, :boolean
      add :keys, :text
      add :followers, {:array, :string}
    end
  end
end
