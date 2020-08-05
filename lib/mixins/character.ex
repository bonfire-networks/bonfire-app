defmodule CommonsPub.Core.Character do

  use Pointers.Mixin,
    otp_app: :cpub_core,
    source: "cpub_character"

  alias CommonsPub.Core.{Character, UsernameReservation}
  alias Ecto.Changeset

  mixin_schema do
    field :username, :string
    field :username_hash, Cloak.Ecto.SHA256
  end

  def create(attrs) do
    %Character{}
    |> Changeset.cast(attrs, [:id, :username])
    |> Changeset.validate_required([:id, :username])
    |> Changeset.unique_constraint([:username])
    |> Changeset.unique_constraint([:username_hash])
    |> hash_username()
  end

  def hash_username(changeset) do
    value = Changeset.get_field(changeset, :username)
    Changeset.put_change(changeset, :username_hash, value)
  end

end
