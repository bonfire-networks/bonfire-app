defmodule VoxPublica.Web.ConfirmEmailController.Test do

  use VoxPublica.ConnCase
  alias VoxPublica.Fake

  describe "request" do

    test "form renders" do
      conn = conn()
      conn = get(conn, "/confirm-email")
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
    end

    test "absence validation" do
      conn = conn()
      conn = post(conn, "/confirm-email", %{})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
      assert [err] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='confirm-email-form_email']")
      assert "can't be blank" == Floki.text(err)
    end

    test "format validation" do
      conn = conn()
      conn = post(conn, "/confirm-email", %{"confirm_email_form" => %{"email" => Faker.Pokemon.name()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
      assert [err] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='confirm-email-form_email']")
      assert "has invalid format" == Floki.text(err)
    end

    test "not found" do
      conn = conn()
      conn = post(conn, "/confirm-email", %{"confirm_email_form" => %{"email" => Fake.email()}})
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [err] = Floki.find(doc, ".error")
      assert Floki.text(err) =~ ~r/invalid confirmation link/i
    end

    # TODO
    # test "expired" do
    #   conn = conn()
    # end

  end

  describe "confirmation" do

    test "not found" do
      conn = conn()
      conn = get(conn, "/confirm-email/#{Fake.confirm_token()}")
      doc = floki_response(conn)
      assert [form] = Floki.find(doc, "#confirm-email-form")
      assert [_] = Floki.find(form, "#confirm-email-form_email")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [err] = Floki.find(doc, ".error")
      assert Floki.text(err) =~ ~r/invalid confirmation link/i
    end

    test "success" do
      conn = conn()
      account = fake_account!()
      conn = get(conn, "/confirm-email/#{account.email.confirm_token}")
      assert redirected_to(conn) == "/home"
    end

    test "twice confirm" do
      conn = conn()
      account = fake_account!()
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
