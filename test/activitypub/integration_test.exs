defmodule Bonfire.ActivityPub.IntegrationTest do
  use Bonfire.ConnCase

  test "fetch users from AP API" do
    user = fake_user!()

    conn =
      build_conn()
      |> get("/pub/actors/#{user.character.username}")
      |> response(200)
      |> Jason.decode!

    assert conn["preferredUsername"] == user.character.username
    assert conn["name"] == user.profile.name
    assert conn["summary"] == user.profile.summary
  end
end
