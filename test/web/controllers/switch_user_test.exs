defmodule CommonsPub.WebPhoenix.SwitchUserController.Test do

  use VoxPublica.ConnCase
  alias VoxPublica.Fake

  describe "index" do

    test "not logged in" do
      conn = conn()
      conn = get(conn, "/switch-user")
      assert redirected_to(conn) == "/login"
      conn = get(recycle(conn), "/login")
      doc = floki_response(conn)
      assert [err] = find_flash(doc)
      assert_flash(err, :error, ~r/must log in/)
    end

    test "no users" do
      account = fake_account!()
      conn = conn(account: account)
      conn = get(conn, "/switch-user")
      assert redirected_to(conn) == "/create-user"
      conn = get(recycle(conn), "/create-user")
      doc = floki_response(conn)
      assert [err] = find_flash(doc)
      assert_flash(err, :info, ~r/fill out/)
    end

    test "shows users" do
      account = fake_account!()
      alice = fake_user!(account)
      bob = fake_user!(account)
      conn = conn(account: account)
      conn = get(conn, "/switch-user")
      doc = floki_response(conn)
      [a, b] = Floki.find(doc,  "user__list h3")
      assert Floki.text(a) == "@#{alice.character.username}"
      assert Floki.text(b) == "@#{bob.character.username}"
    end

  end

  describe "show" do

    test "not logged in" do
      conn = conn()
      conn = get(conn, "/switch-user/@#{Fake.username()}")
      assert redirected_to(conn) == "/login"
      conn = get(recycle(conn), "/login")
      doc = floki_response(conn)
      assert [err] = find_flash(doc)
      assert_flash(err, :error, ~r/must log in/)
    end

    test "not found" do
      account = fake_account!()
      _user = fake_user!(account)
      conn = conn(account: account)
      conn = get(conn, "/switch-user/@#{Fake.username()}")
      assert redirected_to(conn) == "/switch-user"
      conn = get(recycle(conn), "/switch-user")
      doc = floki_response(conn)
      assert [err] = find_flash(doc)
      assert_flash(err, :error, ~r/does not exist/)
    end

    test "not permitted" do
      alice = fake_account!()
      bob = fake_account!()
      _alice_user = fake_user!(alice)
      bob_user = fake_user!(bob)
      conn = conn(account: alice)
      conn = get(conn, "/switch-user/@#{bob_user.character.username}")
      assert redirected_to(conn) == "/switch-user"
      conn = get(recycle(conn), "/switch-user")
      doc = floki_response(conn)
      assert [err] = find_flash(doc)
      assert_flash(err, :error, ~r/not permitted/)
    end

    test "success" do
      account = fake_account!()
      user = fake_user!(account)
      conn = conn(account: account)
      conn = get(conn, "/switch-user/@#{user.character.username}")
      assert redirected_to(conn) == "/home/@#{user.character.username}"
      conn = get(conn, "/home/@#{user.character.username}")
      assert get_session(conn, :username) == user.character.username
      doc = floki_response(conn)
      assert [err] = find_flash(doc)
      assert_flash(err, :info, "Welcome back, @#{user.character.username}!")
    end

  end

end
