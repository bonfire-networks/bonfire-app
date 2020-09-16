defmodule VoxPublica.Repo do
  use Ecto.Repo,
    otp_app: :vox_publica,
    adapter: Ecto.Adapters.Postgres

  alias Pointers.Changesets
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

  @doc """
  Like `insert/1`, but understands remapping changeset errors to attr
  names from config (and only config, no overrides at present!).
  """
  def put(%Changeset{}=changeset) do
    with {:error, changeset} <- insert(changeset) do
      Changesets.rewrite_constraint_errors(changeset)
    end
  end


  def put_many(things) do
    case Enum.filter(things, fn {_, %Changeset{valid?: v}} -> not v end) do
      [] -> transact_with(fn -> put_many(things, %{}) end)
      failed -> {:error, failed}
    end
  end

  defp put_many([], acc), do: {:ok, acc}
  defp put_many([{k, v} | is], acc) do
    case insert(v) do
      {:ok, v} -> put_many(is, Map.put(acc, k, v))
      {:error, other} -> {:error, {k, other}}
    end
  end

  @doc """
  Like Repo.one, but returns an ok/error tuple.
  """
  def single(q), do: single2(one(q))

  defp single2(nil), do: {:error, :not_found}
  defp single2(other), do: {:ok, other}


end
