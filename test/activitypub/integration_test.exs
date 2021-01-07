defmodule Bonfire.ActivityPub.IntegrationTest do
  use Bonfire.ConnCase
  alias Bonfire.Me.Fake
  alias Bonfire.Me.Identity.{Accounts, Users}

  test "fetch users from AP API" do
    attrs = fake_user!()

    conn =
      build_conn()
      |> get("/pub/actors/#{attrs.character.username}")
      |> response(200)
      |> Jason.decode!

    assert conn["preferredUsername"] == attrs.character.username
    assert conn["name"] == attrs.profile.name
    assert conn["summary"] == attrs.profile.summary
  end
end
