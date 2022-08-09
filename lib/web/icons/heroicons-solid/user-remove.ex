defmodule Iconify.HeroiconsSolid.UserRemove do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="currentColor" d="M11 6a3 3 0 1 1-6 0a3 3 0 0 1 6 0Zm3 11a6 6 0 0 0-12 0h12Zm-1-9a1 1 0 1 0 0 2h4a1 1 0 1 0 0-2h-4Z"/></svg>
    """
  end
end
