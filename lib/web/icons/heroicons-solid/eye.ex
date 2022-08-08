defmodule Iconify.HeroiconsSolid.Eye do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><g fill="currentColor"><path d="M10 12a2 2 0 1 0 0-4a2 2 0 0 0 0 4Z"/><path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10ZM14 10a4 4 0 1 1-8 0a4 4 0 0 1 8 0Z" clip-rule="evenodd"/></g></svg>
    """
  end
end
