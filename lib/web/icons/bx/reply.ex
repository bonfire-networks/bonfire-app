defmodule Iconify.Bx.Reply do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M10 11h6v7h2v-8a1 1 0 0 0-1-1h-7V6l-5 4l5 4v-3z"/></svg>
    """
  end
end
