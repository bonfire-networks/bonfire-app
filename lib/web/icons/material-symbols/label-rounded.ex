defmodule Iconify.MaterialSymbols.LabelRounded do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M5 19q-.825 0-1.413-.587Q3 17.825 3 17V7q0-.825.587-1.412Q4.175 5 5 5h10q.5 0 .938.225q.437.225.712.625l3.525 5q.375.525.375 1.15q0 .625-.375 1.15l-3.525 5q-.275.4-.712.625Q15.5 19 15 19Z"
      />
    </svg>
    """
  end
end
