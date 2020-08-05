defmodule CommonsPub.Core.Activity do

  use Pointers.Pointable,
    otp_app: :cpub_core,
    source: "vp_activity",
    table_id: "C0MM0NSPVBC0REVERB1SAD01NG"

  alias CommonsPub.Core.{Activity, Verb}
  alias Ecto.Changeset

  pointable_schema do
    belongs_to :verb, Verb
    
  end

  def create(attrs) do
    # %Verb{}
    # |> Changeset.cast(attrs, [:verb])
    # |> Changeset.validate_required([:verb])
    # |> Changeset.unique_constraint(:verb)
  end

end
