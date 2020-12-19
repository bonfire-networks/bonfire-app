defmodule Bonfire.ActivityPub.IntegrationTest do
  use Bonfire.ConnCase
  alias Bonfire.Me.{Accounts, Fake, Users}

  test "fetch users from AP API" do
    assert {:ok, account} = Accounts.signup(Fake.account())
    attrs = Fake.user()
    assert {:ok, user} = Users.create(attrs, account)

    conn =
      build_conn()
      |> get("/pub/actors/#{attrs.username}")
      |> response(200)
      |> Jason.decode!

    assert conn["preferredUsername"] == attrs.username
    assert conn["name"] == attrs.name
    assert conn["summary"] == attrs.summary
  end
end
