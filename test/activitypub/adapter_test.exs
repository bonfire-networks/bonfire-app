defmodule VoxPublica.ActivityPub.AdapterTest do
  use VoxPublica.DataCase
  alias VoxPublica.Accounts
  alias VoxPublica.ActivityPub.Adapter
  alias VoxPublica.Users
  alias VoxPublica.Fake

  describe "actor fetching" do
    test "by username" do
      assert {:ok, account} = Accounts.signup(Fake.account())
      attrs = Fake.user()
      assert {:ok, user} = Users.create(account, attrs)
      assert {:ok, actor} = Adapter.get_actor_by_username(attrs.username)
      assert actor.data["summary"] == attrs.summary
      assert actor.data["preferredUsername"] == attrs.username
      assert actor.data["name"] == attrs.name
      assert actor.username == attrs.username
    end
  end
end
