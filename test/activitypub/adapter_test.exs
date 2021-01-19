defmodule Bonfire.ActivityPub.AdapterTest do
  use Bonfire.DataCase
  alias Bonfire.ActivityPub.Adapter

  describe "actor fetching" do
    test "by username" do
      user = fake_user!()
      assert {:ok, actor} = Adapter.get_actor_by_username(user.character.username)
      assert actor.data["summary"] == user.profile.summary
      assert actor.data["preferredUsername"] == user.character.username
      assert actor.data["name"] == user.profile.name
      assert actor.username == user.character.username
    end
  end
end
