[
  import_deps: [:phoenix, :ecto_sql, :surface],
  inputs: ["*.{ex,exs,sface}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs,sface}", "forks/*/{config,lib,test}/**/*.{ex,exs,sface}"],
  surface_inputs: ["{lib,test}/**/*.{ex,exs,sface}", "forks/*/{lib,test}/**/*.{ex,exs,sface}"],
]
