defmodule CommonsPub.Core.Login do

  use Pointers.Pointable,
    otp_app: :cpub_core,
    source: "vp_verb",
    table_id: "C0MM0NSPVBC0REVERB1SAD01NG"

  alias CommonsPub.Core.Verb
  alias Ecto.Changeset

  pointable_schema do
    field :name, :string
  end

  def create(attrs) do
    %Verb{}
    |> Changeset.cast(attrs, [:verb])
    |> Changeset.validate_required([:verb])
    |> Changeset.unique_constraint(:verb)
  end

end
