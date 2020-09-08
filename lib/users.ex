defmodule VoxPublica.Users do
  @doc """
  A User is a logical identity within the system belonging to an Account.
  """
  alias CommonsPub.Accounts.Account
  alias CommonsPub.Users.User
  alias Pointers.Changesets
  alias VoxPublica.Repo
  import Ecto.Query

  def create(%Account{id: id}, attrs),
    do: Repo.put(changeset(Map.put(attrs, :account_id, id)))

  def changeset(user \\ %User{}, attrs) do
    User.changeset(user, attrs)
    |> Changesets.cast_assoc(:accounted, attrs)
    |> Changesets.cast_assoc(:character, attrs)
    |> Changesets.cast_assoc(:profile, attrs)
  end

  def by_account(%Account{}=account), do: Repo.all(by_account_query(account))

  def by_account_query(%Account{id: account_id}) do
    from u in User,
      join: a in assoc(u, :accounted),
      join: c in assoc(u, :character),
      where: a.account_id == ^account_id,
      preload: [accounted: a, character: c]
  end

end
