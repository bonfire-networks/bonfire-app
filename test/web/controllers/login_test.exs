defmodule CommonsPub.WebPhoenix.LoginController.Test do

  use VoxPublica.ConnCase
  alias CommonsPub.Me.Accounts

  test "form renders" do
    conn = conn()
    conn = get(conn, "/login")
    doc = floki_response(conn)
    assert [form] = Floki.find(doc, "#login-form")
    assert [_] = Floki.find(form, "#login-form_email")
    assert [_] = Floki.find(form, "#login-form_password")
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  describe "required fields" do

    test "missing both" do
      conn = conn()
      conn = post(conn, "/login", %{"login_fields" => %{}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#login-form")
      assert [_] = Floki.find(form, "#login-form_email")
      assert [email_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_email']")
      assert "can't be blank" == Floki.text(email_error)
      assert [_] = Floki.find(form, "#login-form_password")
      assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_password']")
      assert "can't be blank" == Floki.text(password_error)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "missing password" do
      conn = conn()
      email = Fake.email()
      conn = post(conn, "/login", %{"login_fields" => %{"email" => email}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#login-form")
      assert [_] = Floki.find(form, "#login-form_email")
      assert [] == Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_email']")
      assert [_] = Floki.find(form, "#login-form_password")
      assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_password']")
      assert "can't be blank" == Floki.text(password_error)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "missing email" do
      conn = conn()
      password = Fake.password()
      conn = post(conn, "/login", %{"login_fields" => %{"password" => password}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#login-form")
      assert [_] = Floki.find(form, "#login-form_email")
      assert [email_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_email']")
      assert [_] = Floki.find(form, "#login-form_password")
      assert [] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_password']")
      assert "can't be blank" == Floki.text(email_error)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

  end

  test "not found" do
    conn = conn()
    email = Fake.email()
    password = Fake.password()
    params = %{"login_fields" => %{"email" => email, "password" => password}}
    conn = post(conn, "/login", params)
    doc = floki_response(conn)
    assert [div] = Floki.find(doc, "div.box__warning")
    assert [span] = Floki.find(div, "span")
    assert Floki.text(span) =~ ~r/incorrect/
    assert [_] = Floki.find(doc, "#login-form")
  end

  test "not activated" do
    conn = conn()
    account = fake_account!()
    params = %{"login_fields" =>
                %{"email" => account.email.email,
                  "password" => account.login_credential.password}}
    conn = post(conn, "/login", params)
    doc = floki_response(conn)
    assert [div] = Floki.find(doc, "div.box__warning")
    assert [span] = Floki.find(div, "span")
    assert Floki.text(span) =~ ~r/confirm/
    assert [_] = Floki.find(doc, "#login-form")
  end

  test "success" do
    conn = conn()
    account = fake_account!()
    {:ok, account} = Accounts.confirm_email(account)
    params = %{"login_fields" =>
                %{"email" => account.email.email,
                  "password" => account.login_credential.password}}
    conn = post(conn, "/login", params)
    assert redirected_to(conn) == "/switch-user"
  end

end
