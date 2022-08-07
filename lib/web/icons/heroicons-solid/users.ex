defmodule Iconify.HeroiconsSolid.Users do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="currentColor" d="M9 6a3 3 0 1 1-6 0a3 3 0 0 1 6 0Zm8 0a3 3 0 1 1-6 0a3 3 0 0 1 6 0Zm-4.07 11c.046-.327.07-.66.07-1a6.97 6.97 0 0 0-1.5-4.33A5 5 0 0 1 19 16v1h-6.07ZM6 11a5 5 0 0 1 5 5v1H1v-1a5 5 0 0 1 5-5Z"/></svg>
    """
  end
end
