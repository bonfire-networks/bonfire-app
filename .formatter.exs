[
  import_deps: [
    # :beacon, :beacon_live_admin,
    :surface,
    :phoenix,
    :ecto,
    :ecto_sql,
    :assert_value,
    :mneme
  ],
  plugins: [Phoenix.LiveView.HTMLFormatter, Surface.Formatter.Plugin],

  # add patterns matching all .sface files and all .ex files with ~F sigils
  inputs: [
    "{mix,.formatter,mess}.exs",
    "{flavours,lib,test}/**/*.{ex,exs,sface,heex}",
    "extensions/*/{config,lib,test}/**/*.{ex,exs,sface,heex}",
    "forks/bonfire*/{config,lib,test}/**/*.{ex,exs,sface,heex}",
    "forks/{untangle,voodoo,zest,pointers,pointers_ulid,nodeinfo,iconify_ex,grumble,flexto,emote.ecto_sparkles,activity_pub,absinthe_client}/{config,lib,test}/**/*.{ex,exs,heex}"
  ],
  subdirectories: ["priv/*/migrations"],

  # THE FOLLOWING ARE OPTIONAL:

  # set desired line length for both Elixir's code formatter and this one
  # (only affects opening tags in Surface)
  line_length: 98

  # heex_line_length: 84,

  # or, set line length only for Surface code (overrides `line_length`)
  # surface_line_length: 84
]
