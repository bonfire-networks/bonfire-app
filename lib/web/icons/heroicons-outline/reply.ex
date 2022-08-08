defmodule Iconify.HeroiconsOutline.Reply do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 0 1 8 8v2M3 10l6 6m-6-6l6-6"/></svg>
    """
  end
end
