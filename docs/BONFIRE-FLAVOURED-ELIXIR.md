# Bonfire-flavoured Elixir

Bonfire has a few libraries that are widely used in the codebase and make writing Elixir feel a little bit different. To help you get less confused by this, here's a guide on what we can call "bonfire-flavoured elixir"!

Please note this guide assumes you already know [Elixir](https://elixir-lang.org/getting-started/introduction.html).

## `Arrows`

The Elixir [|> ("pipe") operator](https://hexdocs.pm/elixir/Kernel.html#%7C%3E/2) is one of the things that seems to get people excited about elixir. Probably in part because you then don't have to keep coming up with function names. Unfortunately it's kind of limiting. 
The moment you need to pipe a parameter into a position that isn't the first one, it breaks down and you have to drop out of the pipeline format or write a secondary function to handle it.

Not any more! By simply inserting `...` where you would like the value to be inserted, `Arrows` will override where it is placed. This allows you to keep on piping while accommodating that function with the annoying argument order. `Arrows` was inspired by [an existing library](https://hexdocs.pm/magritte/Magritte.html). Here is part of the test suite in lieu of examples:

```elixir
defmodule ArrowsTest do
  use ExUnit.Case
  use Arrows

  def double(x), do: x * 2
  def double_fst(x, _), do: x * 2
  def double_snd(_, x), do: x * 2
  def add_snd_thd(_, x, y), do: x + y

  test "|>" do
    assert 4 == (2 |> double)
    assert 4 == (2 |> double())
    assert 4 == (2 |> double(...))
    assert 8 == (2 |> double(double(...)))
    assert 4 == (2 |> double_fst(1))
    assert 4 == (2 |> double_fst(..., 1))
    assert 8 == (2 |> double_fst(double(...), 1))
    assert 4 == (2 |> double_snd(1, ...))
    assert 8 == (2 |> double_snd(1, double(...)))
    assert 3 == (2 |> add_snd_thd(1, ..., 1))
    assert 4 == (2 |> add_snd_thd(1, ..., ...))
    assert 6 == (2 |> add_snd_thd(1, ..., double(...)))
    for x <- [:yes, 2, nil, false] do
      assert {:ok, x} == (x |> {:ok, ...})
    end
  end
end
```

A few little extra features you might notice here:
* You can move the parameter into a subexpression, as in `2 |> double_fst(double(...), 1)` where
  double will be called before the parameter is passed to `double_fst`.
* You can use `...` multiple times, substituting it in multiple places.
* The right hand side need not even be a function call, you can use any expression with `...`.

### Ok-pipe

`Arrows` also provides an `ok-pipe` operator, `~>`, which only pipes into the next function if the result from the last one was considered a success. It's inspired by [OK](https://hexdocs.pm/ok/readme.html), but we have chosen to do things slightly differently so it better fits with our regular pipe.

input                    | result          |
:----------------------- | :-------------- |
`{:ok, x}`               | `fun.(x)`       |
`{:error, e}`            | `{:error, e}`   |
`nil`                    | `nil`           |
`x when not is_nil(x)`   | `fun.(x)`       |

In the case of a function returning an ok/error tuple being on the left hand side, this is straightforward to determine. In the event of `{:ok, x}`, x will be passed into the right hand side to call. In the event of `{:error, x}`, the result will be `{:error, x}`.

We also deal with a lot of functions that indicate failure by returning nil. `~>` tries to 'do what I mean' for both of these so you can have one pipe operator to rule them all. If `nil` is a valid result, you must thus be sure to wrap it in an `ok` tuple when it occurs on the left hand side of `~>`.

`|>` and `~>` compose in the way you'd expect; i.e. a `~>` receiving an error tuple or nil will stop executing the rest of the chain of (mixed) pipes.

## Untangle

`Untangle` provides replacements for the macros in Elixir's `Logger` module and the `IO.inspect` function to output code location information. The first argument will be `inspect`ed and the second (where provided) will be used as a label:

```
iex(1)> import Untangle
Untangle
iex(2)> debug(:no, "the answer is") # log at debug
11:19:09.915 [debug] [iex:2] the answer is: :no
:no
iex(3)> dump(%{a: :map}, "it") # inspect something on stdout
[iex:3] it: %{a: :map}
%{a: :map}
```

When used in a code file, the location information becomes slightly more useful, e.g.:

```
[lib/test_untangle.ex:15@Test.Untangle.example/2] Here's an empty list: []
```

You may also notice from the iex output that it returns its first argument. This makes it ideal for
inserting into a pipeline for debugging purposes:

```elixir
do_something()
|> debug("output of do_something/0")
```

When you are done debugging something, the location of the debug statement is already in the output so you know where to remove it or comment it out! Bliss!

You will find the codebase uses this a lot, though the debugs are frequently commented out. Just uncomment the ones that would help you with a particular debugging task and you're off.
