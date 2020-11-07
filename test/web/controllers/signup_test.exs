defmodule CommonsPub.WebPhoenix.SignupController.Test do

  use VoxPublica.ConnCase

  test "form renders" do
    conn = conn()
    conn = get(conn, "/signup")
    doc = floki_response(conn)
    assert [form] = Floki.find(doc, "#signup-form")
    assert [_] = Floki.find(form, "#signup-form_email")
    assert [_] = Floki.find(form, "#signup-form_password")
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  describe "required fields" do

    test "missing both" do
      conn = conn()
      conn = post(conn, "/signup", %{"signup_fields" => %{}})
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

    test "missing password" do
      conn = conn()
      email = Fake.email()
      conn = post(conn, "/signup", %{"signup_fields" => %{"email" => email}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#signup-form")
      assert [_] = Floki.find(form, "#signup-form_email")
      assert [] == Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_email']")
      assert [_] = Floki.find(form, "#signup-form_password")
      assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_password']")
      assert "can't be blank" == Floki.text(password_error)
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    test "missing email" do
      conn = conn()
      password = Fake.password()
      conn = post(conn, "/signup", %{"signup_fields" => %{"password" => password}})
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

  test "success" do
    conn = conn()
    email = Fake.email()
    password = Fake.password()
    conn = post(conn, "/signup", %{"signup_fields" => %{"email" => email, "password" => password}})
    doc = floki_response(conn)
    assert [div] = Floki.find(doc, "div.form__confirmation")
    assert [p] = Floki.find(div, "p")
    assert Floki.text(p) =~ ~r/mailed.+you a link/s
    assert [] = Floki.find(doc, "#signup-form")
  end

end
