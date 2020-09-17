defmodule VoxPublica.UsersTest do

  use VoxPublica.DataCase, async: true
  alias VoxPublica.{Accounts, Fake, Users}

  test "creation works" do
    assert {:ok, account} = Accounts.signup(Fake.account())
    attrs = Fake.user()
    assert {:ok, user} = Users.create(attrs, account)
    assert attrs.name == user.profile.name
    assert attrs.summary == user.profile.summary
    assert attrs.username == user.character.username
  end

  test "usernames must be unique" do
    assert {:ok, account} = Accounts.signup(Fake.account)
    attrs = Fake.user()
    assert {:ok, user} = Users.create(attrs, account)
    assert {:error, changeset} = Users.create(attrs, account)
    assert %{character: character, profile: profile} = changeset.changes
    assert profile.valid?
    assert([username: {_,_}] = character.errors)
  end

  test "fetching by username" do
    assert {:ok, account} = Accounts.signup(Fake.account)
    attrs = Fake.user()
    assert {:ok, user} = Users.create(attrs, account)
    assert {:ok, user} = Users.by_username(attrs.username)
    assert user.profile.name == attrs.name
    assert user.profile.summary == attrs.summary
    assert user.character.username == attrs.username
  end
end
