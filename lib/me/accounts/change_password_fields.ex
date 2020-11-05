defmodule CommonsPub.Me.Accounts.ChangePasswordFields do

  use Ecto.Schema
  alias Ecto.Changeset
  alias CommonsPub.Me.Accounts.ChangePasswordFields

  embedded_schema do
    field :old_password, :string
    field :password, :string
    field :password_confirmation, :string
  end

  @cast [:old_password, :password, :password_confirmation]
  @required @cast

  def changeset(form \\ %ChangePasswordFields{}, attrs) do
    form
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.validate_length(:password, min: 10, max: 64)
    |> Changeset.validate_confirmation(:password)
  end

end
