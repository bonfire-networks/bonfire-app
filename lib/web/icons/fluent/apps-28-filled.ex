defmodule Iconify.Fluent.Apps28Filled do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 28 28"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M20.841 2.655a2.25 2.25 0 0 0-3.182 0L13.5 6.815v-.561a2.25 2.25 0 0 0-2.25-2.25h-7A2.25 2.25 0 0 0 2 6.254v18c0 .966.784 1.75 1.75 1.75h18a2.25 2.25 0 0 0 2.25-2.25V16.75a2.25 2.25 0 0 0-2.25-2.25h-.556l4.155-4.155a2.25 2.25 0 0 0 0-3.182l-4.508-4.508ZM13.5 10.694l3.806 3.806H13.5v-3.806ZM12 14.5H3.5V6.254a.75.75 0 0 1 .75-.75h7a.75.75 0 0 1 .75.75V14.5ZM3.5 16H12v8.504H4.25a.75.75 0 0 1-.75-.75V16Zm10 8.504V16h8.25a.75.75 0 0 1 .75.75v7.004a.75.75 0 0 1-.75.75H13.5Z"
      />
    </svg>
    """
  end
end
