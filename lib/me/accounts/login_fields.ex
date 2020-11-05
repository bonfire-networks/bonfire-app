defmodule CommonsPub.Me.Accounts.LoginFields do

  use Ecto.Schema
  alias Ecto.Changeset
  alias CommonsPub.Me.Accounts.LoginFields

  embedded_schema do
    field :form, :string, virtual: true
    field :email, :string
    field :password, :string
  end

  @cast [:email, :password]
  @required @cast

  def changeset(form \\ %LoginFields{}, attrs) do
    form
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
  end

end
