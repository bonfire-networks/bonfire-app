defmodule VoxPublica.Users.CreateForm do

  use Ecto.Schema
  require Pointers.Changesets
  alias Pointers.Changesets
  alias VoxPublica.Users.CreateForm

  embedded_schema do
    field :form, :string, virtual: true
    field :username, :string
    field :name, :string
    field :summary, :string
  end

  @defaults [
    cast: [:username, :name, :summary],
    required: [:username, :name, :summary],
  ]

  def changeset(form \\ %CreateForm{}, attrs, opts \\ []),
    do: Changesets.auto(form, attrs, opts, @defaults)

end
