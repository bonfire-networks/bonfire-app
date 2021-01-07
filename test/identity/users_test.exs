defmodule Bonfire.Me.Identity.UsersTest do

  use Bonfire.DataCase, async: true
  alias Bonfire.Me.Fake
  alias Bonfire.Me.Identity.{Accounts, Users}
  alias Bonfire.Repo

  test "creation works" do
    assert {:ok, account} = Accounts.signup(Fake.signup_form())
    attrs = Fake.create_user_form()
    assert {:ok, user} = Users.create(attrs, account)
    user = Repo.preload(user, [:profile, :character])
    assert attrs.character.username == user.character.username
    assert attrs.profile.name == user.profile.name
    assert attrs.profile.summary == user.profile.summary
  end

  test "usernames must be unique" do
    assert {:ok, account} = Accounts.signup(Fake.signup_form())
    attrs = Fake.create_user_form()
    assert {:ok, _user} = Users.create(attrs, account)
    assert {:error, changeset} = Users.create(attrs, account)
    assert %{character: character, profile: profile} = changeset.changes
    assert profile.valid?
    assert([username: {_,_}] = character.errors)
  end

  test "fetching by username" do
    assert {:ok, account} = Accounts.signup(Fake.signup_form())
    attrs = Fake.create_user_form()
    assert {:ok, _user} = Users.create(attrs, account)
    assert {:ok, user} = Users.by_username(attrs.character.username)
    assert user.character.username == attrs.character.username
    assert user.profile.name == attrs.profile.name
    assert user.profile.summary == attrs.profile.summary
  end
end
