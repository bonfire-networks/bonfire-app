defmodule Iconify.HeroiconsSolid.QuestionMarkCircle do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" fill-rule="evenodd" d="M18 10a8 8 0 1 1-16 0a8 8 0 0 1 16 0Zm-8-3a1 1 0 0 0-.867.5a1 1 0 1 1-1.731-1A3 3 0 0 1 13 8a3.001 3.001 0 0 1-2 2.83V11a1 1 0 1 1-2 0v-1a1 1 0 0 1 1-1a1 1 0 1 0 0-2Zm0 8a1 1 0 1 0 0-2a1 1 0 0 0 0 2Z" clip-rule="evenodd"/></svg>
    """
  end
end
