defmodule VoxPublica.AccountsTest do

  use VoxPublica.DataCase, async: true
  alias VoxPublica.{Accounts, Fake}

  describe "[registration]" do

    test "works" do
      attrs = Fake.account()
      assert {:ok, account} = Accounts.signup(attrs)
      assert account.login_credential.identity == attrs[:email]
      assert Argon2.verify_pass(attrs[:password], account.login_credential.password_hash)
    end

    test "emails must be unique" do
      attrs = Fake.account()
      assert {:ok, account} = Accounts.signup(attrs)
      assert account.login_credential.identity == attrs[:email]
      assert Argon2.verify_pass(attrs[:password], account.login_credential.password_hash)
      assert {:error, :taken} = Accounts.signup(attrs)
    end

  end

  describe "[confirm_email]" do

    test "works given an account" do
      attrs = Fake.account()
      assert {:ok, account} = Accounts.signup(attrs)
      assert {:ok, account} = Accounts.confirm_email(account)
      assert account.email.email_confirmed_at
      assert is_nil(account.email.email_confirm_token)
    end

  end

  describe "[login]" do

    test "account must have a confirmed email" do
      attrs = Fake.account()
      assert {:ok, account} = Accounts.signup(attrs)
      assert {:error, :email_not_confirmed} == Accounts.login(attrs)
    end

    test "success" do
      attrs = Fake.account()
      assert {:ok, account} = Accounts.signup(attrs)
      {:ok, _} = Accounts.confirm_email(account)
      assert {:ok, account} = Accounts.login(attrs)
      assert account.email.email == attrs[:email]
    end

  end


end
