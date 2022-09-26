defmodule Rauversion.Repo.Migrations.CreateEventTickets do
  use Ecto.Migration

  def change do
    create table(:event_tickets) do
      add(:title, :string)
      add(:price, :decimal)
      add(:early_bird_price, :decimal)
      add(:standard_price, :decimal)
      add(:qty, :integer)
      add(:selling_start, :utc_datetime)
      add(:selling_end, :utc_datetime)
      add(:short_description, :string)
      add(:settings, :map)
      add(:event_id, references(:events, on_delete: :nothing))

      timestamps()
    end

    create(index(:event_tickets, [:event_id]))
  end
end
