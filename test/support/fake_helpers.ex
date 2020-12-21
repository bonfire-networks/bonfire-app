defmodule Bonfire.Test.FakeHelpers do

  alias Bonfire.Data.Identity.Account
  alias Bonfire.Me.Fake
  alias Bonfire.Me.Identity.{Accounts, Users}

  import ExUnit.Assertions

  @repo Bonfire.Repo

  def fake_account!(attrs \\ %{}) do
    assert {:ok, account} = Accounts.signup(signup_form(attrs), must_confirm: false)
    account
  end

  def fake_user!(account \\ %{}, attrs \\ %{})

  def fake_user!(%Account{}=account, attrs) do
    assert {:ok, user} = Users.create(Fake.user(attrs), account)
    user
  end

  def fake_user!(account_attrs, user_attrs) do
    fake_user!(fake_account!(account_attrs), user_attrs)
  end


end
