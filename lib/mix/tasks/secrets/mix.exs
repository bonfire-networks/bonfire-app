defmodule Bonfire.Secrets do
  use Mix.Project

  def project do
    [
      app: :secrets,
      version: "0.1.0-alpha.1",
      elixir: "~> 1.11",
      escript: [main_module: Mix.Tasks.Bonfire.Secrets]
    ]
  end

end
