defmodule VoxPublica.Test.FakeHelpers do

  alias CommonsPub.Accounts.Account
  alias VoxPublica.{Accounts, Fake, Repo, Users}
  import ExUnit.Assertions

  def fake_account!(attrs \\ %{}) do
    cs = Accounts.signup_changeset(Fake.account(attrs))
    assert {:ok, account} = Repo.insert(cs)
    account
  end

  def fake_user!(%Account{}=account, attrs \\ %{}) do
    assert {:ok, user} = Users.create(account, Fake.user(attrs))
    user
  end

end
