defmodule VoxPublica.Accounts do

  alias CommonsPub.Accounts.Account
  alias Ecto.Changeset
  alias Pointers.Changesets
  alias VoxPublica.Accounts.LoginForm
  alias VoxPublica.Repo
  import Ecto.Query

  def register(attrs), do: Repo.insert(changeset(attrs))

  def changeset(attrs) do
    %Account{email: nil, login_credential: nil}
    |> Account.changeset(attrs)
    |> Changesets.cast_assoc(:email, attrs)
    |> Changesets.cast_assoc(:login_credential, attrs)
  end

  def login(attrs) do
    cs = LoginForm.changeset(attrs)
    login_check_attrs(Changeset.apply_action(cs, :insert), cs)
  end

  defp login_check_attrs({:ok, form}, changeset) do
    find_for_login_query(form.email)
    |> login_check_password(form, changeset)
  end

  @no_match "Unknown email or incorrect password."

  defp login_check_password(nil, _form, changeset) do
    Argon2.no_user_verify()
    {:error, Changeset.add_error(changeset, :form, @no_match)}
  end

  defp login_check_password(account, form, changeset) do
    if Argon2.verify_pass(form.password, account.login_credential.password_hash),
      do: {:ok, account},
      else: {:error, Changeset.add_error(changeset, :form, @no_match)}
  end

  defp find_for_login_query(email) when is_binary(email) do
    from a in Account,
      join: lc in assoc(a, :login_credential),
      where: lc.identity == ^email,
      preload: [login_credential: lc]
  end

  # def confirm_email(token) when is_binary(token) do
  #   Repo.transact_with fn ->
  #     case Repo.one(find_for_confirm_email_query(token)) do
  #       nil -> {:error, :not_found}
  #       %Account{email: %Email{}=email}=account ->
  #         with {:ok, email} <- Repo.update(Email.confirm(email)) do
  #           {:ok, %{ account | email: email } }
  #         end
  #     end
  #   end
  # end

  defp find_for_confirm_email_query(token) when is_binary(token) do
    from a in Account,
      join: e in assoc(a, :email),
      where: e.email_token == ^token,
      preload: [email: e]
  end

end
