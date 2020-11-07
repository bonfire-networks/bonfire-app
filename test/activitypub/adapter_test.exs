defmodule Bonfire.ActivityPub.AdapterTest do
  use Bonfire.DataCase
  alias Bonfire.Me.Accounts
  alias Bonfire.ActivityPub.Adapter
  alias Bonfire.Me.Users
  alias Bonfire.Fake

  describe "actor fetching" do
    test "by username" do
      assert {:ok, account} = Accounts.signup(Fake.account())
      attrs = Fake.user()
      assert {:ok, user} = Users.create(attrs, account)
      assert {:ok, actor} = Adapter.get_actor_by_username(attrs.username)
      assert actor.data["summary"] == attrs.summary
      assert actor.data["preferredUsername"] == attrs.username
      assert actor.data["name"] == attrs.name
      assert actor.username == attrs.username
    end
  end
end
