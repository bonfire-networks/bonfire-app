defmodule VoxPublica.Accounts.ConfirmEmailForm do

  use Ecto.Schema
  alias Ecto.Changeset
  alias VoxPublica.Accounts.ConfirmEmailForm

  embedded_schema do
    field :email, :string
  end

  @cast [:email]
  @required @cast

  def changeset(form \\ %ConfirmEmailForm{}, attrs) do
    form
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.validate_format(:email, ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$))
  end

end
