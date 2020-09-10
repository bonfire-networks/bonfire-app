defmodule VoxPublica.Web.SignupLive.Test do

  use VoxPublica.ConnCase

  test "disconnected", %{conn: conn} do
    conn = get(conn, "/signup")
    doc = floki_response(conn)
    assert [form] = Floki.find(doc, "#signup-form")
    assert [_] = Floki.find(form, "#signup-form_email")
    assert [_] = Floki.find(form, "#signup-form_password")
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  test "required fields", %{conn: conn} do
    {view, doc} = floki_live(conn, "/signup")
    assert [form] = Floki.find(doc, "#signup-form")
    assert [email_input] = Floki.find(form, "#signup-form_email")
    assert [password_input] = Floki.find(form, "#signup-form_password")
    assert [submit] = Floki.find(form, "button[type='submit']")
    doc = floki_submit(view, :submit, %{"signup_form" => %{}})
    assert [form] = Floki.find(doc, "#signup-form")
    assert [_] = Floki.find(form, "#signup-form_email")
    assert [email_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_email']")
    assert "can't be blank" == Floki.text(email_error)
    assert [_] = Floki.find(form, "#signup-form_password")
    assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_password']")
    assert "can't be blank" == Floki.text(password_error)
    assert [_] = Floki.find(form, "button[type='submit']")
    email = Fake.email()
    password = Fake.password()
    doc = floki_submit(view, :submit, %{"signup_form" => %{"email" => email}})
    assert [form] = Floki.find(doc, "#signup-form")
    assert [_] = Floki.find(form, "#signup-form_email")
    assert [] == Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_email']")
    assert [_] = Floki.find(form, "#signup-form_password")
    assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_password']")
    assert "can't be blank" == Floki.text(password_error)
    assert [_] = Floki.find(form, "button[type='submit']")
    doc = floki_submit(view, :submit, %{"signup_form" => %{"password" => password}})
    assert [form] = Floki.find(doc, "#signup-form")
    assert [_] = Floki.find(form, "#signup-form_email")
    assert [_] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_email']")
    assert [_] = Floki.find(form, "#signup-form_password")
    assert [] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='signup-form_password']")
    assert "can't be blank" == Floki.text(password_error)
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  test "success", %{conn: conn} do
    {view, _} = floki_live(conn, "/signup")
    email = Fake.email()
    password = Fake.password()
    doc = floki_submit(view, :submit, %{"signup_form" => %{"email" => email, "password" => password}})
    assert [div] = Floki.find(doc, "div.info")
    assert [span] = Floki.find(div, "span")
    assert Floki.text(span) =~ ~r/mailed.+you a link/s
    assert [] = Floki.find(doc, "#signup-form")
  end

end
