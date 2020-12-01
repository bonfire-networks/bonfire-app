defmodule Bonfire.Test.FakeHelpers do

  alias Bonfire.Data.Identity.Account
  alias Bonfire.{Fake, Repo}
  alias Bonfire.Me.{Accounts, Users}
  import ExUnit.Assertions

  def fake_account!(attrs \\ %{}) do
    cs = Accounts.signup_changeset(Fake.account(attrs))
    assert {:ok, account} = Repo.insert(cs)
    account
  end

  def fake_user!(%Account{}=account, attrs \\ %{}) do
    assert {:ok, user} = Users.create(Fake.user(attrs), account)
    user
  end

end
