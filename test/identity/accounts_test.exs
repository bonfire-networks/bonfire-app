defmodule Bonfire.Me.Identity.AccountsTest do

  use Bonfire.DataCase, async: true
  alias Bonfire.Me.Fake
  alias Bonfire.Me.Identity.Accounts

  describe "[registration]" do

    test "works" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs)
      assert account.email.email_address == attrs[:email][:email_address]
      assert Argon2.verify_pass(attrs[:credential][:password], account.credential.password_hash)
    end

    test "emails must be unique" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs)
      assert account.email.email_address == attrs[:email][:email_address]
      assert Argon2.verify_pass(attrs[:credential][:password], account.credential.password_hash)
      assert {:error, changeset} = Accounts.signup(attrs)
      assert changeset.changes.email.errors[:email_address]
    end

  end

  describe "[confirm_email]" do

    test "works given an account" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs)
      assert {:ok, account} = Accounts.confirm_email(account)
      assert account.email.confirmed_at
      assert is_nil(account.email.confirm_token)
    end

  end

  describe "[login]" do

    test "an account must have a confirmed email when must_confirm is true by default" do
      attrs = Fake.signup_form()
      assert {:ok, _account} = Accounts.signup(attrs)
      attrs = %{email: attrs[:email][:email_address], password: attrs[:credential][:password]}
      assert {:error, :email_not_confirmed} == Accounts.login(attrs)
    end

    test "an account's email will be automatically confirmed when must_confirm is false" do
      attrs = Fake.signup_form()
      assert {:ok, _account} = Accounts.signup(attrs, must_confirm: false)
      attrs = %{email: attrs[:email][:email_address], password: attrs[:credential][:password]}
      assert {:ok, _account} = Accounts.login(attrs)
    end

    test "an account with a confirmed email may log in successfully" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs)
      {:ok, _} = Accounts.confirm_email(account)
      attrs = %{email: attrs[:email][:email_address], password: attrs[:credential][:password]}
      assert {:ok, account} = Accounts.login(attrs)
      assert account.email.email_address == attrs[:email]
    end

  end

end
