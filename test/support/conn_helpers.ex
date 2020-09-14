defmodule VoxPublica.ConnHelpers do

  import ExUnit.Assertions
  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint VoxPublica.Web.Endpoint

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

  def floki_click(view, event, value \\ %{}) do
    assert {:ok, doc} = Floki.parse_fragment(render_click(view, value))
    doc
  end

  def floki_submit(view, event, value \\ %{}) do
    assert {:ok, doc} = Floki.parse_fragment(render_submit(view, event, value))
    doc
  end

end
