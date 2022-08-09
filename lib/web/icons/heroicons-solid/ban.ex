defmodule Iconify.HeroiconsSolid.Ban do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="currentColor" fill-rule="evenodd" d="M13.477 14.89A6 6 0 0 1 5.11 6.524l8.367 8.368Zm1.414-1.414L6.524 5.11a6 6 0 0 1 8.367 8.367ZM18 10a8 8 0 1 1-16 0a8 8 0 0 1 16 0Z" clip-rule="evenodd"/></svg>
    """
  end
end
