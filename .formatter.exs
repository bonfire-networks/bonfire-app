[
  import_deps: [:phoenix, :ecto_sql, :surface],
  inputs: ["*.{ex,exs,sface}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs,sface}", "forks/*/{config,lib,test}/**/*.{ex,exs,sface}"],
  subdirectories: ["priv/*/migrations"]
]
