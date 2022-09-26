defmodule Rauversion.Repo.Migrations.AddPaymentIdAndPaymentProvider do
  use Ecto.Migration

  def change do
    alter table(:purchase_orders) do
      add(:payment_id, :string)
      add(:payment_provider, :string)
      # add :payment_, references(:purchase_orders, on_delete: :nothing)
    end
  end
end
