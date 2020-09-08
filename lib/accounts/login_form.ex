defmodule VoxPublica.Accounts.LoginForm do

  use Ecto.Schema
  alias Ecto.Changeset
  alias VoxPublica.Accounts.LoginForm

  embedded_schema do
    field :form, :string, virtual: true
    field :email, :string
    field :password, :string
  end

  @cast [:email, :password]
  @required @cast

  def changeset(form \\ %LoginForm{}, attrs) do
    form
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(attrs, @required)
  end

end
