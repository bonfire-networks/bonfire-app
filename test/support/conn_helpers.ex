defmodule Bonfire.Test.ConnHelpers do

  import ExUnit.Assertions
  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  # alias CommonsPub.Accounts
  alias Bonfire.Data.Identity.Account
  alias Bonfire.Data.Identity.User

  @endpoint Bonfire.Web.Endpoint

  ### conn

  def session_conn(conn \\ build_conn()), do: Plug.Test.init_test_session(conn, %{})

  def conn(), do: conn(session_conn(), [])
  def conn(%Plug.Conn{}=conn), do: conn(conn, [])
  def conn(filters) when is_list(filters), do: conn(session_conn(), filters)

  def conn(conn, filters) when is_list(filters),
    do: Enum.reduce(filters, conn, &conn(&2, &1))

  def conn(conn, {:account, %Account{id: id}}),
    do: put_session(conn, :account_id, id)

  def conn(conn, {:account, account_id}) when is_binary(account_id),
    do: put_session(conn, :account_id, account_id)

  def conn(conn, {:user, %User{id: id}}),
    do: put_session(conn, :user_id, id)

  def conn(conn, {:user, user_id}) when is_binary(user_id),
    do: put_session(conn, :user_id, user_id)

  def find_flash(doc) do
    messages = Floki.find(doc, "#flash-messages p")
    case messages do
      [_, _ | _] -> throw :too_many_flashes
      short -> short
    end
  end

  def assert_flash(p, kind, message) do
    assert_flash_kind(p, kind)
    assert_flash_message(p, message)
  end

  def assert_flash_kind(flash, :error) do
    classes = floki_attr(flash, :class)
    assert "alert" in classes
    assert "alert-error" in classes
  end

  def assert_flash_kind(flash, :info) do
    classes = floki_attr(flash, :class)
    assert "alert" in classes
    assert "alert-info" in classes
  end

  def assert_flash_message(flash, %Regex{}=r),
    do: assert(Floki.text(flash) =~ r)
  def assert_flash_message(flash, bin) when is_binary(bin),
    do: assert(Floki.text(flash) == bin)

  def find_form_error(doc, name),
    do: Floki.find(doc, "span.invalid-feedback[phx-feedback-for='#{name}']")

  def assert_field_good(doc, name) do
    assert [field] = Floki.find(doc, "#" <> name)
    assert [] == find_form_error(doc, name)
    field
  end

  def assert_field_error(doc, name, error) do
    assert [field] = Floki.find(doc, "#" <> name)
    assert [err] = find_form_error(doc, name)
    assert Floki.text(err) =~ error
    field
  end

  ### floki_attr

  def floki_attr(elem, :class),
    do: Enum.flat_map(floki_attr(elem, "class"), &String.split(&1, ~r/\s+/, trim: true))

  def floki_attr(elem, attr) when is_binary(attr),
    do: Floki.attribute(elem, attr)

  def floki_response(conn, code \\ 200) do
    assert {:ok, html} = Floki.parse_document(html_response(conn, code))
    html
  end

  def floki_live(conn) do
    assert {:ok, view, html} = live(conn)
    assert {:ok, doc} = Floki.parse_document(html)
    {view, doc}
  end

  def floki_live(conn, path) do
    assert {:ok, view, html} = live(conn, path)
    assert {:ok, doc} = Floki.parse_document(html)
    {view, doc}
  end

  def floki_click(view, value \\ %{}) do
    assert {:ok, doc} = Floki.parse_fragment(render_click(view, value))
    doc
  end

  def floki_submit(view, event, value \\ %{}) do
    assert {:ok, doc} = Floki.parse_fragment(render_submit(view, event, value))
    doc
  end

end
