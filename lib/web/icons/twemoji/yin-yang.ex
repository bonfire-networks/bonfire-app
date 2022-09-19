defmodule Iconify.Twemoji.YinYang do
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
        fill="#9266CC"
        d="M36 32a4 4 0 0 1-4 4H4a4 4 0 0 1-4-4V4a4 4 0 0 1 4-4h28a4 4 0 0 1 4 4v28z"
      /><path
        fill="#FFF"
        d="M18.964 4.033C11.251 3.501 4.566 9.322 4.033 17.036s5.289 14.399 13.002 14.931c7.714.533 14.399-5.289 14.931-13.002c.533-7.714-5.288-14.399-13.002-14.932zm-1.183 25.983A6.01 6.01 0 0 1 18 18a6.012 6.012 0 0 0 6.118-5.897c.046-2.558-1.524-4.748-3.758-5.657l.151-.171c5.517 1.174 9.612 6.096 9.506 11.943c-.122 6.639-5.597 11.919-12.236 11.798z"
      /><circle cx="18" cy="24" r="2.5" fill="#FFF" /><circle cx="18" cy="12" r="2.5" fill="#9266CC" />
    </svg>
    """
  end
end
