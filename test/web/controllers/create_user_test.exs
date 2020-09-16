defmodule VoxPublica.Web.CreateUserController.Test do

  use VoxPublica.ConnCase

  test "form renders" do
    alice = fake_account!()
    conn = conn(account: alice)
    conn = get(conn, "/create-user")
    doc = floki_response(conn)
    assert [form] = Floki.find(doc, "#create-form")
    assert [_] = Floki.find(form, "#create-form_username")
    assert [_] = Floki.find(form, "#create-form_name")
    assert [_] = Floki.find(form, "#create-form_summary")
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  describe "required fields" do

    test "missing all" do
      alice = fake_account!()
      conn = conn(account: alice)
      conn = post(conn, "/create-user", %{"create_form" => %{}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#create-form")
      assert [_] = Floki.find(form, "#create-form_username")
      assert_field_error(form, "create-form_username", ~r/can't be blank/)
      assert [_] = Floki.find(form, "#create-form_name")
      assert_field_error(form, "create-form_name", ~r/can't be blank/)
      assert [_] = Floki.find(form, "#create-form_summary")
      assert_field_error(form, "create-form_summary", ~r/can't be blank/)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "with name" do
      alice = fake_account!()
      conn = conn(account: alice)
      conn = post(conn, "/create-user", %{"create_form" => %{"name" => Fake.name()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#create-form")
      assert_field_good(form, "create-form_name")
      assert_field_error(form, "create-form_username", ~r/can't be blank/)
      assert_field_error(form, "create-form_summary", ~r/can't be blank/)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "with username" do
      alice = fake_account!()
      conn = conn(account: alice)
      conn = post(conn, "/create-user", %{"create_form" => %{"username" => Fake.username()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#create-form")
      assert_field_good(form, "create-form_username")
      assert_field_error(form, "create-form_name", ~r/can't be blank/)
      assert_field_error(form, "create-form_summary", ~r/can't be blank/)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "with summary" do
      alice = fake_account!()
      conn = conn(account: alice)
      conn = post(conn, "/create-user", %{"create_form" => %{"summary" => Fake.summary()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#create-form")
      assert_field_good(form, "create-form_summary")
      assert_field_error(form, "create-form_username", ~r/can't be blank/)
      assert_field_error(form, "create-form_name", ~r/can't be blank/)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "missing username" do
      alice = fake_account!()
      conn = conn(account: alice)
      conn = post(conn, "/create-user", %{"create_form" => %{"summary" => Fake.summary(), "name" => Fake.name()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#create-form")
      assert_field_good(form, "create-form_summary")
      assert_field_good(form, "create-form_name")
      assert_field_error(form, "create-form_username", ~r/can't be blank/)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "missing name" do
      alice = fake_account!()
      conn = conn(account: alice)
      conn = post(conn, "/create-user", %{"create_form" => %{"summary" => Fake.summary(), "username" => Fake.username()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#create-form")
      assert_field_good(form, "create-form_summary")
      assert_field_good(form, "create-form_username")
      assert_field_error(form, "create-form_name", ~r/can't be blank/)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "missing summary" do
      alice = fake_account!()
      conn = conn(account: alice)
      conn = post(conn, "/create-user", %{"create_form" => %{"name" => Fake.name(), "username" => Fake.username()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#create-form")
      assert_field_good(form, "create-form_username")
      assert_field_good(form, "create-form_name")
      assert_field_error(form, "create-form_summary", ~r/can't be blank/)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

  end

  test "username taken" do
    alice = fake_account!()
    user = fake_user!(alice)
    conn = conn(account: alice)
    params = %{"create_form" => %{"summary" => Fake.summary(), "name" => Fake.name(), "username" => user.character.username}}
    conn = post(conn, "/create-user", params)
    doc = floki_response(conn)
    assert [form] = Floki.find(doc, "#create-form")
    assert_field_good(form, "create-form_summary")
    assert_field_good(form, "create-form_name")
    assert_field_error(form, "create-form_username", ~r/has already been taken/)
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  test "success" do
    alice = fake_account!()
    conn = conn(account: alice)
    username = Fake.username()
    params = %{"create_form" => %{"summary" => Fake.summary(), "name" => Fake.name(), "username" => username}}
    conn = post(conn, "/create-user", params)
    assert redirected_to(conn) == "/home/@#{username}"
    conn = get(recycle(conn), "/home/@#{username}")
    doc = floki_response(conn)
    assert [err] = find_flash(doc)
    assert_flash(err, :info, ~r/all ready/)
  end

end
