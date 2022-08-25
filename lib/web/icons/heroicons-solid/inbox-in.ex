defmodule Iconify.HeroiconsSolid.InboxIn do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><g fill="currentColor"><path d="M8.707 7.293a1 1 0 0 0-1.414 1.414l2 2a1 1 0 0 0 1.414 0l2-2a1 1 0 0 0-1.414-1.414L11 7.586V3a1 1 0 1 0-2 0v4.586l-.293-.293Z"/><path d="M3 5a2 2 0 0 1 2-2h1a1 1 0 0 1 0 2H5v7h2l1 2h4l1-2h2V5h-1a1 1 0 1 1 0-2h1a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5Z"/></g></svg>
    """
  end
end
