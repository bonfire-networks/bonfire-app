%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "mix.exs",
          "flavours/",
          "lib/",
          "forks/*/mix.exs",
          "forks/*/lib"
        ],
        excluded: [~r"/_build/", "**/*_test.exs"]
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: true
      # checks: [
      #   {Credo.Check.Design.AliasUsage, priority: :low},
      #   # ... other checks omitted for readability ...
      # ]
    }
  ]
}
