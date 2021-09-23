defmodule Mix.Tasks.Bonfire.Secrets do
  @shortdoc "Generates some secrets"

  @moduledoc """
  Generates secrets and prints to the terminal.
      mix secrets [length]
  By default, it generates keys 64 characters long.
  The minimum value for `length` is 32.
  """
  use Mix.Task

  def main(args) do # for running as escript
    run(args)
  end

  @doc false
  def run([]),    do: run(["64"])
  def run([int]), do: int |> parse!() |> random_string() |> Kernel.<>("\r\n") |> IO.puts()
  def run([int, iterate]), do: for _ <- 1..parse!(iterate), do: run([int])
  def run(args), do: invalid_args!(args)

  defp parse!(int) do
    case Integer.parse(int) do
      {int, ""} -> int
      _ -> invalid_args!(int)
    end
  end

  defp random_string(length) when length > 31 do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end
  defp random_string(_), do: raise "Secrets should be at least 32 characters long"

  defp invalid_args!(args) do
    raise "Expected a length as integer or no argument at all, got #{inspect args}"
  end
end
