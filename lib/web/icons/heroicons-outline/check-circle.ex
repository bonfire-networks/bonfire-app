defmodule Iconify.HeroiconsOutline.CheckCircle do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m9 12l2 2l4-4m6 2a9 9 0 1 1-18 0a9 9 0 0 1 18 0Z"/></svg>
    """
  end
end
