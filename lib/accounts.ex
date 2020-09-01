defmodule VoxPublica.Accounts do

  alias CommonsPub.Accounts.Account
  alias Pointers.Changesets
  alias VoxPublica.Repo
  import Ecto.Query

  def create(attrs) do
    create_changeset(attrs)
    |> Repo.insert()
  end

  def create_changeset(attrs) do
    Account.changeset(attrs)
    |> Changesets.cast_assoc(:email, attrs)
    |> Changesets.cast_assoc(:login_credential, attrs)
  end

  def find_for_login_query(email) when is_binary(email) do
    from a in Account,
      join: lc in assoc(a, :login_credential),
      where: lc.identity == ^email,
      preload: [login_credential: lc]
  end

  def authenticate(email, password) do
    case Repo.one(find_for_login_query(email)) do
      nil -> Argon2.no_user_verify()
      account -> auth(account, password)
    end
  end

  defp auth(account, password) do
    if Argon2.verify_pass(password, account.login_credential.password_hash),
      do: {:ok, account},
      else: {:error, :not_found}
  end

end
