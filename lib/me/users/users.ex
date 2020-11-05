defmodule CommonsPub.Me.Users do
  @doc """
  A User is a logical identity within the system belonging to an Account.
  """
  use OK.Pipe
  alias CommonsPub.Accounts.Account
  alias CommonsPub.Users.User
  alias CommonsPub.Me.Users.UserFields
  alias Pointers.Changesets
  alias Ecto.Changeset
  import Ecto.Query

  @repo Application.get_env(:cpub_me, :repo_module)

  @type changeset_name :: :create

  @spec changeset(changeset_name, attrs :: map, %Account{}) :: Changeset.t
  def changeset(:create, attrs, %Account{}=account), do: UserFields.changeset(attrs, account)

  def create(attrs, %Account{}=account) when not is_struct(attrs),
    do: create(changeset(:create, attrs, account))

  defp create(%Changeset{data: %UserFields{}}=cs),
    do: Changeset.apply_action(cs, :insert) ~>> create()

  defp create(%UserFields{}=form) do
    Map.from_struct(form)
    |> create_changeset()
    |> @repo.put()
  end

  def update(%User{} = user, attrs), do: @repo.update(create_changeset(user, attrs))

  def create_changeset(user \\ %User{}, attrs) do
    User.changeset(user, attrs)
    |> Changesets.cast_assoc(:accounted, attrs)
    |> Changesets.cast_assoc(:character, attrs)
    |> Changesets.cast_assoc(:profile, attrs)
    |> Changesets.cast_assoc(:actor, attrs)
  end

  def by_account(%Account{id: id}), do: by_account(id)
  def by_account(account_id) when is_binary(account_id),
    do: @repo.all(by_account_query(account_id))

  def by_account_one(account_id) when is_binary(account_id),
    do: @repo.all(by_account_query(account_id, 1))

  def by_account_query(account_id, limit \\ 100) do
    from u in User,
      join: a in assoc(u, :accounted),
      join: c in assoc(u, :character),
      where: a.account_id == ^account_id,
      preload: [accounted: a, character: c],
      limit: ^limit
  end

  def by_username(username), do: @repo.single(by_username_query(username))

  def by_username_query(username) do
    from u in User,
      join: p in assoc(u, :profile),
      join: c in assoc(u, :character),
      join: a in assoc(u, :actor),
      join: ac in assoc(u, :accounted),
      where: c.username == ^username,
      preload: [profile: p, character: c, actor: a, accounted: ac]
  end

  def for_switch_user(username, account_id) do
    @repo.single(for_switch_user_query(username))
    ~>> check_account_id(account_id)
  end

  def check_account_id(%User{}=user, account_id) do
    if user.accounted.account_id == account_id,
      do: {:ok, user},
      else: {:error, :not_permitted}
  end

  def for_switch_user_query(username) do
    from u in User,
      join: c in assoc(u, :character),
      join: a in assoc(u, :accounted),
      where: c.username == ^username,
      preload: [character: c, accounted: a],
      order_by: [asc: u.id]
  end

end
