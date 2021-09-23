defmodule Bonfire.Release do
  use Mix.Project

  def project do
    [
      app: :release,
      version: "0.1.0-alpha.1",
      elixir: "~> 1.11",
      escript: [main_module: Mix.Tasks.Bonfire.Release]
    ]
  end

end
