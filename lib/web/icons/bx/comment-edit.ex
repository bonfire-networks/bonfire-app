defmodule Iconify.Bx.CommentEdit do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="currentColor" d="m13.771 9.123l-1.399-1.398l-3.869 3.864v1.398h1.398zM14.098 6l1.398 1.398l-1.067 1.067l-1.398-1.398z"/><path fill="currentColor" d="M20 2H4c-1.103 0-2 .897-2 2v18l5.333-4H20c1.103 0 2-.897 2-2V4c0-1.103-.897-2-2-2zm0 14H6.667L4 18V4h16v12z"/></svg>
    """
  end
end
