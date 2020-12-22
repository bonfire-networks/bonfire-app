defmodule Bonfire.Me.Identity.AccountsTest do

  use Bonfire.DataCase, async: true
  alias Bonfire.Data.Identity.Credential
  alias Bonfire.Me.Fake
  alias Bonfire.Me.Identity.Accounts

  describe "signup" do

    test "email: :valid" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs)
      assert Credential.check_password(attrs.credential.password, account.credential.password_hash)
      assert account.email.email_address == attrs.email.email_address
      assert account.email.confirm_token
      assert account.email.confirm_until
      assert nil == account.email.confirmed_at
    end

    test "email: :valid, must_confirm?: false" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs, must_confirm?: false)
      assert account.email.email_address == attrs.email.email_address
      assert account.email.confirmed_at
      assert nil == account.email.confirm_token
      assert nil == account.email.confirm_until
      assert Credential.check_password(attrs.credential.password, account.credential.password_hash)
    end

    test "email: :exists" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs)
      assert account.email.email_address == attrs.email.email_address
      assert Credential.check_password(attrs.credential.password, account.credential.password_hash)
      assert {:error, changeset} = Accounts.signup(attrs)
      assert changeset.changes.email.errors[:email_address]
    end

  end

  describe "request_confirm_email" do

    # TODO

  end

  describe "confirm_email" do

    # TODO: with: :token

    test "with: :account" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs)
      assert {:ok, account} = Accounts.confirm_email(account)
      assert account.email.confirmed_at
      assert is_nil(account.email.confirm_token)
      assert {:ok, _account} = Accounts.confirm_email(account)
    end

  end

  describe "login" do

    # TODO: by username

    test "by: :email, confirmed: false" do
      attrs = Fake.signup_form()
      assert {:ok, _account} = Accounts.signup(attrs)
      assert {:error, changeset} = Accounts.login %{
        email_or_username: attrs.email.email_address,
        password: attrs.credential.password,
      }
      assert changeset.errors[:form] == {"email_not_confirmed", []}
    end

    test "by: :email, confirmed: true" do
      attrs = Fake.signup_form()
      assert {:ok, account} = Accounts.signup(attrs)
      {:ok, _} = Accounts.confirm_email(account)
      assert {:ok, account} = Accounts.login %{
        email_or_username: attrs.email.email_address,
        password: attrs.credential.password,
      }
      assert account.email.email_address == attrs.email.email_address
    end

    test "by: :email, confirmed: :auto" do
      attrs = Fake.signup_form()
      assert {:ok, _account} = Accounts.signup(attrs, must_confirm?: false)
      assert {:ok, _account} = Accounts.login %{
        email_or_username: attrs.email.email_address,
        password: attrs.credential.password,
      }
    end

    test "by: :email, must_confirm?: false" do
      attrs = Fake.signup_form()
      assert {:ok, _account} = Accounts.signup(attrs)
      assert {:ok, _account} = Accounts.login %{
        email_or_username: attrs.email.email_address,
        password: attrs.credential.password,
      }, must_confirm?: false
    end

  end

end
