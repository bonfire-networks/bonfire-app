defmodule VoxPublica.Web.LoginController.Test do

  use VoxPublica.ConnCase
  alias VoxPublica.Accounts

  test "form renders", %{conn: conn} do
    conn = get(conn, "/login")
    doc = floki_response(conn)
    assert [form] = Floki.find(doc, "#login-form")
    assert [_] = Floki.find(form, "#login-form_email")
    assert [_] = Floki.find(form, "#login-form_password")
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  describe "required fields" do

    test "missing both", %{conn: conn} do
      conn = post(conn, "/login", %{"login_form" => %{}})
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

    test "missing password", %{conn: conn} do
      email = Fake.email()
      conn = post(conn, "/login", %{"login_form" => %{"email" => email}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#login-form")
      assert [_] = Floki.find(form, "#login-form_email")
      assert [] == Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_email']")
      assert [_] = Floki.find(form, "#login-form_password")
      assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_password']")
      assert "can't be blank" == Floki.text(password_error)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "missing email", %{conn: conn} do
      password = Fake.password()
      conn = post(conn, "/login", %{"login_form" => %{"password" => password}})
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

  test "not found", %{conn: conn} do
    email = Fake.email()
    password = Fake.password()
    params = %{"login_form" => %{"email" => email, "password" => password}}
    conn = post(conn, "/login", params)
    doc = floki_response(conn)
    assert [div] = Floki.find(doc, "div.box__warning")
    assert [span] = Floki.find(div, "span")
    assert Floki.text(span) =~ ~r/incorrect/
    assert [_] = Floki.find(doc, "#login-form")
  end

  test "not activated", %{conn: conn} do
    {:ok, account} = Accounts.signup(Fake.account())
    params = %{"login_form" =>
                %{"email" => account.email.email,
                  "password" => account.login_credential.password}}
    conn = post(conn, "/login", params)
    doc = floki_response(conn)
    assert [div] = Floki.find(doc, "div.box__warning")
    assert [span] = Floki.find(div, "span")
    assert Floki.text(span) =~ ~r/confirm/
    assert [_] = Floki.find(doc, "#login-form")
  end

  test "success", %{conn: conn} do
    {:ok, account} = Accounts.signup(Fake.account())
    {:ok, account} = Accounts.confirm_email(account)
    params = %{"login_form" =>
                %{"email" => account.email.email,
                  "password" => account.login_credential.password}}
    conn = post(conn, "/login", params)
    assert redirected_to(conn) == "/home"
  end

end
