alias Recode.Task

[
  version: "0.4.0",
  # Can also be set/reset with "--autocorrect"/"--no-autocorrect".
  autocorrect: true,
  # With "--dry" no changes will be written to the files.
  # Can also be set/reset with "--dry"/"--no-dry".
  # If dry is true then verbose is also active.
  dry: true,
  # Can also be set/reset with "--verbose"/"--no-verbose".
  verbose: true,
  # Can be overwriten by calling `mix recode "lib/**/*.ex"`.
  inputs: [
    "{flavours,lib,test}/**/*.{ex,exs}",
    "forks/bonfire*/{config,lib,test}/**/*.{ex,exs}"
  ],
  formatter: {Recode.Formatter, []},
  tasks: [
    # Tasks could be added by a tuple of the tasks module name and an options
    # keyword list. A task can be deactived by `active: false`. The execution of
    # a deactivated task can be forced by calling `mix recode --task ModuleName`.
    {Task.AliasExpansion, []},
    {Task.AliasOrder, active: false},
    {Task.EnforceLineLength, active: false},
    {Task.PipeFunOne, []},
    {Task.SinglePipe, active: false}, # Note: does not known how to handle `Arrows`
    {Task.Specs, active: false, exclude: "{test}/**/*.{ex,exs}", config: [only: :visible]},
    {Task.TestFileExt, []},
    {Task.UnusedVariable, active: false}
  ]
]
