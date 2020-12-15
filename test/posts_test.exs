defmodule Bonfire.Me.PostsTest do
  use Bonfire.DataCase

  alias Bonfire.Me.Social.Posts
  alias Bonfire.Me.Identity.Accounts
  alias Bonfire.Me.Identity.Users
  alias Bonfire.Me.Fake

  test "creation works" do
    attrs = %{summary: "summary", name: "name", html_content: "<p>epic html message</p>"}
    assert {:ok, account} = Accounts.signup(Fake.account())
    user_attrs = Fake.user()
    assert {:ok, user} = Users.create(user_attrs, account)
    assert {:ok, post} = Posts.create(user, attrs)
    assert post.post_content.html_content == "<p>epic html message</p>"
    assert post.post_content.name == "name"
    assert post.post_content.summary == "summary"
    assert post.created.creator_id == user.id
  end
end
