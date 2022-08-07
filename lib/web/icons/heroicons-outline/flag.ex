defmodule Iconify.HeroiconsOutline.Flag do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 21v-4m0 0V5a2 2 0 0 1 2-2h6.5l1 1H21l-3 6l3 6h-8.5l-1-1H5a2 2 0 0 0-2 2Zm9-13.5V9"/></svg>
    """
  end
end
