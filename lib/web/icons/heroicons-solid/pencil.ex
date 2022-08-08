defmodule Iconify.HeroiconsSolid.Pencil do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M13.586 3.586a2 2 0 1 1 2.828 2.828l-.793.793l-2.828-2.828l.793-.793Zm-2.207 2.207L3 14.172V17h2.828l8.38-8.379l-2.83-2.828Z"/></svg>
    """
  end
end
