defmodule VoxPublica.Test.FakeHelpers do

  alias CommonsPub.Accounts.Account
  alias VoxPublica.{Fake, Repo}
  alias CommonsPub.Me.{Accounts, Users}
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
