defmodule VoxPublica.Web.ConfirmEmailController.Test do

  use VoxPublica.ConnCase
  alias VoxPublica.{Accounts, Fake}

  describe "request" do

    test "form renders", %{conn: conn} do
      conn = get(conn, "/confirm-email")
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
    end

    test "absence validation", %{conn: conn} do
      conn = post(conn, "/confirm-email", %{})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
      assert [err] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='confirm-email-form_email']")
      assert "can't be blank" == Floki.text(err)
    end

    test "format validation", %{conn: conn} do
      conn = post(conn, "/confirm-email", %{"confirm_email_form" => %{"email" => Faker.Pokemon.name()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
      assert [err] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='confirm-email-form_email']")
      assert "has invalid format" == Floki.text(err)
    end

    test "not found", %{conn: conn} do
      conn = post(conn, "/confirm-email", %{"confirm_email_form" => %{"email" => Fake.email()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [err] = Floki.find(doc, ".error")
      assert Floki.text(err) =~ ~r/invalid confirmation link/i
    end

    # TODO
    # test "expired", %{conn: conn} do
    # end

  end

  describe "confirmation" do

    test "not found", %{conn: conn} do
      conn = get(conn, "/confirm-email/#{Fake.confirm_token()}")
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [err] = Floki.find(doc, ".error")
      assert Floki.text(err) =~ ~r/invalid confirmation link/i
    end

    test "success", %{conn: conn} do
      {:ok, account} = Accounts.signup(Fake.account())
      conn = get(conn, "/confirm-email/#{account.email.confirm_token}")
      assert redirected_to(conn) == "/home"
    end

    test "twice confirm", %{conn: conn} do
      {:ok, account} = Accounts.signup(Fake.account())
      conn = get(conn, "/confirm-email/#{account.email.confirm_token}")
      assert redirected_to(conn) == "/home"
      conn = get(build_conn(), "/confirm-email/#{account.email.confirm_token}")
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [err] = Floki.find(doc, ".error")
      assert Floki.text(err) =~ ~r/invalid confirmation link/i
    end
  end

end
