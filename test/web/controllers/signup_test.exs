defmodule VoxPublica.Web.SignupController.Test do

  use VoxPublica.ConnCase

  test "form renders", %{conn: conn} do
    conn = get(conn, "/signup")
    doc = floki_response(conn)
    assert [form] = Floki.find(doc, "#signup-form")
    assert [_] = Floki.find(form, "#signup-form_email")
    assert [_] = Floki.find(form, "#signup-form_password")
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  describe "required fields" do

    test "missing both", %{conn: conn} do
      conn = post(conn, "/signup", %{"signup_form" => %{}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#signup-form")
      assert [_] = Floki.find(form, "#signup-form_email")
      assert [email_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_email']")
      assert "can't be blank" == Floki.text(email_error)
      assert [_] = Floki.find(form, "#signup-form_password")
      assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_password']")
      assert "can't be blank" == Floki.text(password_error)
      assert [_] = Floki.find(form, "button[type='submit']")
    end
    
    test "missing password", %{conn: conn} do
      email = Fake.email()
      conn = post(conn, "/signup", %{"signup_form" => %{"email" => email}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#signup-form")
      assert [_] = Floki.find(form, "#signup-form_email")
      assert [] == Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_email']")
      assert [_] = Floki.find(form, "#signup-form_password")
      assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_password']")
      assert "can't be blank" == Floki.text(password_error)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "missing email", %{conn: conn} do
      password = Fake.password()
      conn = post(conn, "/signup", %{"signup_form" => %{"password" => password}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#signup-form")
      assert [_] = Floki.find(form, "#signup-form_email")
      assert [email_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_email']")
      assert [_] = Floki.find(form, "#signup-form_password")
      assert [] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_password']")
      assert "can't be blank" == Floki.text(email_error)
      assert [_] = Floki.find(form, "button[type='submit']")
    end
  end

  test "success", %{conn: conn} do
    email = Fake.email()
    password = Fake.password()
    conn = post(conn, "/signup", %{"signup_form" => %{"email" => email, "password" => password}})
    doc = floki_response(conn)
    assert [div] = Floki.find(doc, "div.form__confirmation")
    assert [p] = Floki.find(div, "p")
    assert Floki.text(p) =~ ~r/mailed.+you a link/s
    assert [] = Floki.find(doc, "#signup-form")
  end

end
