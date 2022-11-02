defmodule Iconify.Fluent.Status24Filled do
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
        d="M12 3c1.248 0 2.436.254 3.516.712L14.361 4.88a7.5 7.5 0 1 0 4.781 4.826l1.165-1.175A9 9 0 1 1 12 3Zm9.163-.427l.138.128c.938.937.941 2.456.008 3.397l-6.755 6.816a1 1 0 0 1-.41.25l-4.348 1.37a.2.2 0 0 1-.25-.25l1.371-4.353a1 1 0 0 1 .244-.404l6.758-6.819a2.387 2.387 0 0 1 3.244-.135Z"
      />
    </svg>
    """
  end
end
