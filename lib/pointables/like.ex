defmodule CommonsPub.Likes.Like do

  use Pointers.Pointable,
    otp_app: :vox_publica,
    source: "vp_like",
    table_id: "C0MM0NSPVB11KES11KET011KE0"

  pointable_schema do
    
  end

  # use Pointers.Schema
  # alias Ecto.Changeset
  # alias Pointers.ULID
  # alias Pointers.Pointer
  # alias CommonsPub.Likes.Like

  # pointable_schema("cpub_likes_like", "C0MM0NSPVB11KES11KET011KE0") do
  #   belongs_to :target, Pointer
  # end

  # def create(attrs) do
  #   %Like{}
  #   |> Changeset.cast(attrs, [:target])
  #   |> Changeset.change(id: ULID.generate())
  # end

end
