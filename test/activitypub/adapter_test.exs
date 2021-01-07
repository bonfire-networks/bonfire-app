defmodule Bonfire.ActivityPub.AdapterTest do
  use Bonfire.DataCase
  alias Bonfire.Me.{Accounts, Fake, Users}
  alias Bonfire.ActivityPub.Adapter

  describe "actor fetching" do
    test "by username" do
      attrs = fake_user!()
      assert {:ok, actor} = Adapter.get_actor_by_username(attrs.character.username)
      assert actor.data["summary"] == attrs.profile.summary
      assert actor.data["preferredUsername"] == attrs.character.username
      assert actor.data["name"] == attrs.profile.name
      assert actor.username == attrs.character.username
    end
  end
end
