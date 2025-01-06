# SPDX-FileCopyrightText: 2025 Bonfire Networks <https://bonfirenetworks.org/contact/>
#
# SPDX-License-Identifier: CC0-1.0

[
  version: "0.7.3",
  # Can also be set/reset with `--autocorrect`/`--no-autocorrect`.
  autocorrect: true,
  # With "--dry" no changes will be written to the files.
  # Can also be set/reset with `--dry`/`--no-dry`.
  # If dry is true then verbose is also active.
  dry: true,
  # Enables or disables color in the output.
  color: true,
  # Can also be set/reset with `--verbose`/`--no-verbose`.
  verbose: true,
  # Can be overwritten by calling `mix recode "lib/**/*.ex"`.
  inputs: [
    "{flavours,lib,test}/**/*.{ex,exs}",
    "forks/bonfire*/{config,lib,test}/**/*.{ex,exs}",
    "extensions/*/{config,lib,test}/*.{ex,exs}"
  ],
  formatters: [Recode.CLIFormatter],
  tasks: [
    # Tasks could be added by a tuple of the tasks module name and an options
    # keyword list. A task can be deactivated by `active: false`. The execution of
    # a deactivated task can be forced by calling `mix recode --task ModuleName`.
    {Recode.Task.AliasExpansion, []},
    {Recode.Task.AliasOrder, [active: false]},
    {Recode.Task.Dbg, [autocorrect: false]},
    {Recode.Task.EnforceLineLength, [active: false]},
    {Recode.Task.FilterCount, []},
    {Recode.Task.IOInspect, [autocorrect: false]},
    {Recode.Task.LocalsWithoutParens, [active: false]},
    {Recode.Task.Moduledoc, []},
    {Recode.Task.Nesting, []},
    {Recode.Task.PipeFunOne, []},
    {Recode.Task.SinglePipe, [active: false]},
    {Recode.Task.Specs,
     [active: false, exclude: "{test}/**/*.{ex,exs}", config: [only: :visible]]},
    {Recode.Task.TagFIXME, [exit_code: 2]},
    {Recode.Task.TagTODO, [exit_code: 4]},
    {Recode.Task.TestFileExt, []},
    {Recode.Task.UnnecessaryIfUnless, []},
    {Recode.Task.UnusedVariable, []}
  ]
]