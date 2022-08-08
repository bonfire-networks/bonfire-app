defmodule Iconify.HeroiconsSolid.Mail do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><g fill="currentColor"><path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0 0 16 4H4a2 2 0 0 0-1.997 1.884Z"/><path d="m18 8.118l-8 4l-8-4V14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8.118Z"/></g></svg>
    """
  end
end
