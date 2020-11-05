defmodule CommonsPub.Me.Accounts.ConfirmEmailFields do

  use Ecto.Schema
  alias Ecto.Changeset
  alias CommonsPub.Me.Accounts.ConfirmEmailFields

  embedded_schema do
    field :email, :string
  end

  @cast [:email]
  @required @cast

  def changeset(form \\ %ConfirmEmailFields{}, attrs) do
    form
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.validate_format(:email, ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$))
  end

end
