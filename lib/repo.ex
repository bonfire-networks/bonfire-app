defmodule VoxPublica.Repo do
  use Ecto.Repo,
    otp_app: :vox_publica,
    adapter: Ecto.Adapters.Postgres
end
