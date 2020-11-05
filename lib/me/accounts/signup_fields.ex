defmodule CommonsPub.Me.Accounts.SignupFields do

  use Ecto.Schema
  alias Ecto.Changeset
  alias CommonsPub.Me.Accounts.SignupFields

  embedded_schema do
    field :email, :string
    field :password, :string
  end

  @cast [:email, :password]
  @required @cast

  def changeset(form \\ %SignupFields{}, attrs) do
    form
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.validate_format(:email, ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$))
    |> Changeset.validate_length(:password, min: 10, max: 64)
  end

end
