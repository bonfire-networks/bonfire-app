defmodule Iconify.HeroiconsOutline.Pencil do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 20 20" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 1 1 3.536 3.536L6.5 21.036H3v-3.572L16.732 3.732Z"/></svg>
    """
  end
end
