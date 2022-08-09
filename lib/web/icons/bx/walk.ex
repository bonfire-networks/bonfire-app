defmodule Iconify.Bx.Walk do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><circle cx="13" cy="4" r="2" fill="currentColor"/><path fill="currentColor" d="M13.978 12.27c.245.368.611.647 1.031.787l2.675.892l.633-1.896l-2.675-.892l-1.663-2.495a2.016 2.016 0 0 0-.769-.679l-1.434-.717a1.989 1.989 0 0 0-1.378-.149l-3.193.797a2.002 2.002 0 0 0-1.306 1.046l-1.794 3.589l1.789.895l1.794-3.589l2.223-.556l-1.804 8.346l-3.674 2.527l1.133 1.648l3.675-2.528c.421-.29.713-.725.82-1.225l.517-2.388l2.517 1.888l.925 4.625l1.961-.393l-.925-4.627a2 2 0 0 0-.762-1.206l-2.171-1.628l.647-3.885l1.208 1.813z"/></svg>
    """
  end
end
