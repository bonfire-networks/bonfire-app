defmodule Bonfire.Me.PostsTest do
  use Bonfire.DataCase

  alias Bonfire.Me.Social.Posts

  test "creation works" do
    attrs = %{summary: "summary", name: "name", html_content: "<p>epic html message</p>"}
    assert {:ok, post} = Posts.create(nil, attrs)
    assert post.post_content.html_content == "<p>epic html message</p>"
    assert post.post_content.name == "name"
    assert post.post_content.summary == "summary"
  end
end
