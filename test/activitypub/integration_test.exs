defmodule VoxPublica.ActivityPub.IntegrationTest do
  use VoxPublica.ConnCase

  alias VoxPublica.Accounts
  alias VoxPublica.Users
  alias VoxPublica.Fake

  test "fetch users from AP API" do
    assert {:ok, account} = Accounts.register(Fake.account())
    attrs = Fake.user()
    assert {:ok, user} = Users.create(account, attrs)

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
