defmodule Iconify.Bxs.FlagAlt do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="m14.303 6l-3-2H6V2H4v20h2v-8h4.697l3 2H20V6z"/></svg>
    """
  end
end
