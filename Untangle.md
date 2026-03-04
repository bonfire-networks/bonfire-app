# Untangle

Logging/inspecting data, and timing functions, with code location information.

## Logging/inspecting
`Untangle` provides alternatives for `IO.inspect` and the macros in Elixir's `Logger` to output code location information. It also provides a polyfill for `dbg` which was introduce in Elixir 1.14

![screenshot](priv/screenshot.png "Screenshot showing sample logs (shown when running the library tests)")

The first argument is `inspect`ed and the second argument (if provided) is used as a label:

```
> import Untangle
Untangle
> debug(:no, "the answer is") # log at debug
11:19:09.915 [debug] [iex:2] the answer is: :no
:no
> dump(%{a: :map}, "it") # inspect something on stdout
[iex:3] it: %{a: :map}
%{a: :map}
```

When used in a code file, the location information becomes more useful, e.g.:

```
[lib/test_untangle.ex:15@Test.Untangle.example/2] Here's an empty list: []
```

You may also notice from the iex output that it returns its first argument. This makes it ideal for inserting into a pipeline for debugging purposes:

```elixir
do_something()
|> debug("output of do_something/0")
```

When you are done debugging something, the location of the debug statement is already in the output so you know where to remove it, comment it out, or simply change `warn` or `info` for `debug` if you only need it during development :-)

## Timing functions
You can decorate functions to measure and log their execution time:

```
use Untangle

@decorate time()
def fun(), do: :stuff
```

will output something like `[info] Time to run MyModule.fun/0: 1 ms`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `untangle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:untangle, "~> 0.3"}
  ]
end
```

and adding some config:

```elixir
config :untangle, 
  env: config_env()
```

# Configure as default `dbg/2` handler

## In config/config.exs
`config :elixir, :dbg_callback, {Untangle, :custom_dbg, []}`

# Docs

The docs can be found at [https://hexdocs.pm/untangle](https://hexdocs.pm/untangle).

## Copyright and License

Copyright (c) 2022 Bonfire contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
