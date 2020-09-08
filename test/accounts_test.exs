defmodule VoxPublica.AccountsTest do

  use VoxPublica.DataCase, async: true
  alias VoxPublica.{Accounts, Fake, Repo}

  test "creation works" do
    attrs = Fake.account()
    assert {:ok, account} = Accounts.create(attrs)
    assert account.login_credential.identity == attrs[:email]
    assert Argon2.verify_pass(attrs[:password], account.login_credential.password_hash)
  end

  test "emails must be unique" do
    attrs = Fake.account()
    assert {:ok, account} = Accounts.create(attrs)
    assert account.login_credential.identity == attrs[:email]
    assert Argon2.verify_pass(attrs[:password], account.login_credential.password_hash)
    assert {:error, changeset} = Accounts.create(attrs)
    assert %{email: email, login_credential: lc} = changeset.changes

    if not email.valid?,
      do: assert([email: {_,_}] = email.errors)

    if not lc.valid?,
      do: assert([email: {_,_}] = lc.errors)
  end

end
