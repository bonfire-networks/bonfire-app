defmodule Iconify.MaterialSymbols.VpnKeyRounded do
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
        d="M7 18q-2.5 0-4.25-1.75T1 12q0-2.5 1.75-4.25T7 6q2.025 0 3.538 1.137Q12.05 8.275 12.65 10H21q.825 0 1.413.587Q23 11.175 23 12q0 .9-.625 1.45Q21.75 14 21 14v2q0 .825-.587 1.413Q19.825 18 19 18q-.825 0-1.413-.587Q17 16.825 17 16v-2h-4.35q-.6 1.725-2.112 2.863Q9.025 18 7 18Zm0-4q.825 0 1.412-.588Q9 12.825 9 12t-.588-1.413Q7.825 10 7 10t-1.412.587Q5 11.175 5 12q0 .825.588 1.412Q6.175 14 7 14Z"
      />
    </svg>
    """
  end
end
