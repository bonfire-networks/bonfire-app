defmodule Iconify.Twemoji.Cyclone do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 36 36"
      aria-hidden="true"
    >
      <path
        fill="#55ACEE"
        d="M35.782 24.518a1.699 1.699 0 0 0-.821-1.016c-.802-.436-1.879-.116-2.316.683a13.975 13.975 0 0 1-8.372 6.757a14.096 14.096 0 0 1-10.698-1.144a10.83 10.83 0 0 1-5.242-6.493c-.74-2.514-.495-5.016.552-7.033a9.739 9.739 0 0 0 .164 4.908a9.699 9.699 0 0 0 4.701 5.823a11.84 11.84 0 0 0 8.979.961a11.716 11.716 0 0 0 7.026-5.672a14.217 14.217 0 0 0 1.165-10.898a14.225 14.225 0 0 0-6.883-8.529a17.535 17.535 0 0 0-13.299-1.419A17.358 17.358 0 0 0 .332 9.843a1.71 1.71 0 0 0 .681 2.317c.804.439 1.884.117 2.319-.682a13.959 13.959 0 0 1 8.371-6.755a14.12 14.12 0 0 1 10.699 1.142a10.833 10.833 0 0 1 5.239 6.495c.741 2.514.496 5.017-.552 7.033a9.751 9.751 0 0 0-.162-4.911a9.73 9.73 0 0 0-4.702-5.824a11.856 11.856 0 0 0-8.98-.959A11.716 11.716 0 0 0 6.22 13.37a14.218 14.218 0 0 0-1.165 10.897a14.22 14.22 0 0 0 6.883 8.529a17.479 17.479 0 0 0 8.341 2.141c1.669 0 3.337-.242 4.958-.72a17.351 17.351 0 0 0 10.406-8.399c.219-.399.269-.862.139-1.3zM16.784 14.002c.373-.11.758-.166 1.143-.166a4.063 4.063 0 0 1 3.875 2.901a4.049 4.049 0 0 1-3.879 5.186a4.064 4.064 0 0 1-3.875-2.902a4.047 4.047 0 0 1 2.736-5.019z"
      />
    </svg>
    """
  end
end
