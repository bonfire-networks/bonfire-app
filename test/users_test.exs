defmodule VoxPublica.UsersTest do

  use VoxPublica.DataCase, async: true
  alias VoxPublica.{Accounts, Fake, Users}

  test "creation works" do
    assert {:ok, account} = Accounts.register(Fake.account())
    attrs = Fake.user()
    assert {:ok, user} = Users.create(account, attrs)
    assert attrs.name == user.profile.name
    assert attrs.summary == user.profile.summary
    assert attrs.username == user.character.username
  end

  test "usernames must be unique" do
    assert {:ok, account} = Accounts.register(Fake.account)
    attrs = Fake.user()
    assert {:ok, user} = Users.create(account, attrs)
    assert {:error, changeset} = Users.create(account, attrs)
    assert %{character: character, profile: profile} = changeset.changes
    assert profile.valid?
    assert([username: {_,_}] = character.errors)
  end

end
