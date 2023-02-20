defmodule Rauversion.Repo.Migrations.CreatePurchasedTickets do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:purchased_tickets) do
      add(:state, :string)
      add(:data, :map)
      add(:checked_in, :boolean)
      add(:checked_in_at, :utc_datetime)
      add(:user_id, RauversionExtension.user_table_reference())
      add(:event_ticket_id, references(:event_tickets, on_delete: :nothing))

      timestamps()
    end

    create(index(:purchased_tickets, [:user_id]))
    create(index(:purchased_tickets, [:event_ticket_id]))
  end
end
