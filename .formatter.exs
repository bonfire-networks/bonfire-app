[
  import_deps: [:surface],
  plugins: [Surface.Formatter.Plugin],

  # add patterns matching all .sface files and all .ex files with ~F sigils
  inputs: ["*.{ex,exs}", "{config,lib,test,forks}/**/*.{ex,exs,sface}"],

  # THE FOLLOWING ARE OPTIONAL:

  # set desired line length for both Elixir's code formatter and this one
  # (only affects opening tags in Surface)
  line_length: 80,

  # or, set line length only for Surface code (overrides `line_length`)
  # surface_line_length: 84
]
