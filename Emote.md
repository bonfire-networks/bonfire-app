# Emote

Small lib for converting emoticons and emoji names to emoji characters:

Works with emoji names:
```elixir 
iex> Emote.convert_text("my emoji game is :fire:")
"my emoji game is 🔥"
```

And emoticons (see `lib/emoticons.txt` for the list of supported ones):
```elixir 
iex> Emote.convert_text("my emoji game is :P")
"my emoji game is 😜"
```

You can also provide a list of images that can be used as custom emoji:
```elixir 
iex> Emote.convert_text("I can use images as custom emoji :favicon:", custom_emoji: %{"favicon" => "/favicon.ico"}) 
"I can use images as custom emoji <img class='emoji favicon' alt='favicon' title=':favicon:' src='/favicon.ico' />"
```

Or your own function to handle custom emoji:
```elixir 
> Emote.convert_text("I can define my own function to handle custom emoji :fire:",
   custom_fn: fn word -> 
    case lookup_my_custom_emoji(word) do
      %{label: label, url: url} ->
          " <img alt='#{label || word}' title='#{label}' class='emoji' data-emoji='#{word}' src='#{url}' /> "
          
      _nil_ ->
          word
      end
   end
  )
```


Known limitation:
- Emojis combined together don't work, ex.: ":woo:pile_of_poo:hoo:" would not convert.


## License

WTFPL, as originally forked from https://github.com/danigulyas/smile