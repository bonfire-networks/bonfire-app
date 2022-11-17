defmodule Rauversion.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events) do
      add(:title, :string)
      add(:description, :text)
      add(:slug, :string)
      add(:state, :string)
      add(:timezone, :string)
      add(:event_start, :utc_datetime)
      add(:event_ends, :naive_datetime)
      add(:private, :boolean, default: false, null: false)
      add(:online, :boolean, default: false, null: false)
      add(:location, :string)
      add(:street, :string)
      add(:street_number, :string)
      add(:lat, :decimal)
      add(:lng, :decimal)
      add(:venue, :string)
      add(:country, :string)
      add(:city, :string)
      add(:province, :string)
      add(:postal, :string)
      add(:age_requirement, :string)
      add(:event_capacity, :boolean, default: false, null: false)
      add(:event_capacity_limit, :integer)
      add(:eticket, :boolean, default: false, null: false)
      add(:will_call, :boolean, default: false, null: false)
      add(:order_form, :map)
      add(:widget_button, :map)
      add(:event_short_link, :string)
      add(:tax_rates_settings, :map)
      add(:attendee_list_settings, :map)
      add(:scheduling_settings, :map)
      add(:event_settings, :map)
      add(:tickets, :map)
      add(:user_id, RauversionExtension.user_table_reference())

      timestamps()
    end

    create(index(:events, [:user_id]))
  end
end
