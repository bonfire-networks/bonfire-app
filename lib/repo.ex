defmodule VoxPublica.Repo do
  use Ecto.Repo,
    otp_app: :vox_publica,
    adapter: Ecto.Adapters.Postgres

  alias Ecto.Changeset

  def transact_with(fun) do
    transaction fn ->
      case fun.() do
        {:ok, val} -> val
        {:error, val} -> rollback(val)
        val -> val # naughty
      end
    end
  end

  # def put(%Changeset{}=changeset) do
  #   with {:error, changeset} <- insert(changeset) do
  #     changes = Enum.reduce(changeset.changes, changeset.changes, fn {k, v} ->
  #       case v do
  #         %Changeset{valid?: false, errors: errors} ->
  #           :ok
  #       end
  #     end)
  #     {:error, %{ changeset | changes: changes }}
  #   end
  # end


  def insert_many(things) do
    case Enum.filter(things, fn {_, %Changeset{valid?: v}} -> not v end) do
      [] -> transact_with(fn -> im(things, %{}) end)
      failed -> {:error, failed}
    end
  end

  defp im([], acc), do: {:ok, acc}
  defp im([{k, v} | is], acc) do
    case insert(v) do
      {:ok, v} -> im(is, Map.put(acc, k, v))
      {:error, other} -> {:error, {k, other}}
    end
  end

end
