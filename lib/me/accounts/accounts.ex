defmodule CommonsPub.Me.Accounts do

  use OK.Pipe
  alias CommonsPub.Accounts.Account
  alias CommonsPub.Emails.Email
  alias Ecto.Changeset
  alias Pointers.Changesets
  alias CommonsPub.Me.Accounts.{
    Emails,
    # ChangeEmailFields,
    ConfirmEmailFields,
    LoginFields,
    ResetPasswordFields,
    ChangePasswordFields,
    SignupFields,
  }
  import Ecto.Query

  @repo Application.get_env(:cpub_me, :repo_module)
  @mailer_module Application.get_env(:cpub_me, :mailer_module)
  @helper Application.get_env(:cpub_me, :helper_module)

  def get_for_session(id) when is_binary(id), do: @repo.get(Account, id)

  @type changeset_name :: :change_password | :confirm_email | :login | :reset_password | :signup

  @spec changeset(changeset_name, attrs :: map) :: Changeset.t
  def changeset(:change_password, attrs) when not is_struct(attrs),
    do: ChangePasswordFields.changeset(attrs)

  def changeset(:confirm_email, attrs) when not is_struct(attrs),
    do: ConfirmEmailFields.changeset(attrs)

  def changeset(:login, attrs) when not is_struct(attrs),
    do: LoginFields.changeset(attrs)

  def changeset(:reset_password, attrs) when not is_struct(attrs),
    do: ResetPasswordFields.changeset(attrs)

  def changeset(:signup, attrs) when not is_struct(attrs),
    do: SignupFields.changeset(attrs)

  @doc false
  def signup_changeset(%SignupFields{}=form),
    do: signup_changeset(Map.from_struct(form))

  def signup_changeset(attrs) when not is_struct(attrs) do
    %Account{email: nil, login_credential: nil}
    |> Account.changeset(attrs)
    |> Changesets.cast_assoc(:email, attrs)
    |> Changesets.cast_assoc(:login_credential, attrs)
  end

  ### signup

  def signup(attrs) when not is_struct(attrs),
    do: signup(changeset(:signup, attrs))

  def signup(%Changeset{data: %SignupFields{}}=cs),
    do: Changeset.apply_action(cs, :insert) ~>> signup()

  def signup(%SignupFields{}=form),
    do: signup(signup_changeset(form))

  def signup(%Changeset{data: %Account{}}=cs) do
    @repo.transact_with fn -> # revert if email send fails
      @repo.put(cs)
      |> @helper.replace_error(:taken)
      ~>> send_confirm_email()
    end
  end

  ### login

  def login(attrs) when not is_struct(attrs),
    do: changeset(:login, attrs) |> login()

  def login(%Changeset{data: %LoginFields{}}=cs) do
    with {:ok, form} <- Changeset.apply_action(cs, :insert) do
      form
      |> find_by_email_query()
      |> @repo.single()
      ~>> check_password(form)
      ~>> check_confirmed()
    end
  end

  defp check_password(nil, _form) do
    Argon2.no_user_verify()
    {:error, :no_match}
  end

  defp check_password(account, form) do
    if Argon2.verify_pass(form.password, account.login_credential.password_hash),
      do: {:ok, account},
      else: {:error, :no_match}
  end

  defp check_confirmed(%Account{email: %{confirmed_at: nil}}),
    do: {:error, :email_not_confirmed}

  defp check_confirmed(%Account{email: %{confirmed_at: _}}=account),
    do: {:ok, account}

  ### request_confirm_email

  def request_confirm_email(params) when not is_struct(params),
    do: request_confirm_email(changeset(:confirm_email, params))

  def request_confirm_email(%Changeset{data: %ConfirmEmailFields{}}=cs),
    do: Changeset.apply_action(cs, :insert) ~>> request_confirm_email()

  def request_confirm_email(%ConfirmEmailFields{}=form) do
    case @repo.one(find_by_email_query(form.email)) do
      nil -> {:error, :not_found}
      %Account{email: _email}=account -> request_confirm_email(account)
    end
  end

  def request_confirm_email(%Account{email: %{}=email}=account) do
    cond do
      not is_nil(email.confirmed_at) -> {:error, :confirmed}

      # why not refresh here? it provides a window of DOS opportunity
      # against a user completing their activation.
      DateTime.utc_now() < email.confirm_until ->
        with {:ok, _} <- @mailer_module.send_now(Emails.confirm_email(account), email.email),
          do: {:ok, :resent, account}

      true ->
        account = refresh_confirm_email_token(account)
        with {:ok, _} <- send_confirm_email(Emails.confirm_email(account)),
          do: {:ok, :refreshed, account}
    end
  end

  defp refresh_confirm_email_token(%Account{email: %Email{}=email}=account) do
    with {:ok, email} <- @repo.update(Email.put_token(email)),
      do: {:ok, %{ account | email: email }}
  end

  ### confirm_email

  def confirm_email(%Account{}=account) do
    with {:ok, email} <- @repo.update(Email.confirm(account.email)),
      do: {:ok, %{ account | email: email } }
  end

  def confirm_email(token) when is_binary(token) do
    @repo.transact_with fn ->
      case @repo.one(find_for_confirm_email_query(token)) do
        nil -> {:error, :not_found}
        %Account{email: %Email{}=email} = account ->
          cond do
            not is_nil(email.confirmed_at) -> {:error, :confirmed, account}
            is_nil(email.confirm_until) -> {:error, :no_expiry, account}
            DateTime.utc_now() < email.confirm_until -> confirm_email(account)
            true -> {:error, :expired, account}
          end
      end
    end
  end

  defp send_confirm_email(%Account{}=account) do
    case @mailer_module.send_now(Emails.confirm_email(account), account.email.email) do
      {:ok, _mail} -> {:ok, account}
      _ -> {:error, :email}
    end
  end

  ### queries

  # defp get_for_session_query(token) when is_binary(token) do
  #   from a in Account,
  #     join: e in assoc(a, :email),
  #     where: e.confirm_token == ^token,
  #     preload: [email: e]
  # end

  defp find_for_confirm_email_query(token) when is_binary(token) do
    from a in Account,
      join: e in assoc(a, :email),
      where: e.confirm_token == ^token,
      preload: [email: e]
  end

  defp find_by_email_query(%{email: email}), do: find_by_email_query(email)
  defp find_by_email_query(email) when is_binary(email) do
    from a in Account,
      join: e in assoc(a, :email),
      join: lc in assoc(a, :login_credential),
      where: lc.identity == ^email,
      preload: [email: e, login_credential: lc]
  end

end
