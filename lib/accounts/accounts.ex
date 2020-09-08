defmodule VoxPublica.Accounts do

  alias CommonsPub.Accounts.Account
  alias CommonsPub.Emails.Email
  alias Ecto.Changeset
  alias Pointers.Changesets
  alias VoxPublica.Accounts.{LoginForm, RegisterForm}
  alias VoxPublica.Repo
  import Ecto.Query

  def register(attrs) do
    changeset = RegisterForm.changeset(attrs)
    with {:ok, form} <- Changeset.apply_action(changeset, :insert),
         {:error, _} <- Repo.put(create_changeset(Map.from_struct(form))) do
      {:error, :taken}
    end
  end

  defp create_changeset(attrs) do
    %Account{email: nil, login_credential: nil}
    |> Account.changeset(attrs)
    |> Changesets.cast_assoc(:email, attrs)
    |> Changesets.cast_assoc(:login_credential, attrs)
  end

  def login(attrs) do
    cs = LoginForm.changeset(attrs)
    login_check_attrs(Changeset.apply_action(cs, :insert))
  end

  defp login_check_attrs({:error, changeset}), do: {:error, changeset}
  defp login_check_attrs({:ok, form}) do
    find_for_login_query(form.email)
    |> Repo.one()
    |> login_check_password(form)
  end

  defp login_check_password(nil, _form) do
    Argon2.no_user_verify()
    {:error, :no_match}
  end

  defp login_check_password(account, form) do
    if Argon2.verify_pass(form.password, account.login_credential.password_hash),
      do: login_check_confirmed(account),
      else: {:error, :no_match}
  end

  defp login_check_confirmed(%Account{email: %{email_confirmed_at: nil}}),
    do: {:error, :email_not_confirmed}

  defp login_check_confirmed(%Account{email: %{email_confirmed_at: _}}=account),
    do: {:ok, account}

  defp find_for_login_query(email) when is_binary(email) do
    from a in Account,
      join: e in assoc(a, :email),
      join: lc in assoc(a, :login_credential),
      where: lc.identity == ^email,
      preload: [email: e, login_credential: lc]
  end

  def confirm_email(%Account{}=account) do
    Repo.transact_with fn ->
      account = Repo.preload(account, :email)
      with {:ok, email} <- Repo.update(Email.confirm(account.email)),
        do: {:ok, %{ account | email: email } }
    end
  end

  def confirm_email(token) when is_binary(token) do
    Repo.transact_with fn ->
      case Repo.one(find_for_confirm_email_query(token)) do
        nil -> {:error, :not_found}
        %Account{email: %Email{}=email}=account ->
          with {:ok, email} <- Repo.update(Email.confirm(email)),
            do: {:ok, %{ account | email: email } }
      end
    end
  end

  defp find_for_confirm_email_query(token) when is_binary(token) do
    from a in Account,
      join: e in assoc(a, :email),
      where: e.email_token == ^token,
      preload: [email: e]
  end

end
