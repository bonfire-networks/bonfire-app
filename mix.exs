Code.eval_file("mess.exs")
defmodule VoxPublica.MixProject do

  use Mix.Project

  def project do
    [
      app: :vox_publica,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      # compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: Mess.deps [
        {:dbg, "~> 1.0", only: [:dev, :test]},
        {:floki, ">= 0.0.0", only: [:dev, :test]},
      ]
    ]
  end

  def application do
    [
      mod: {VoxPublica.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl, :bamboo, :bamboo_smtp]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      "js.deps.get": ["cmd npm install --prefix assets"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "cpub.deps.update": ["deps.update pointers cpub_accounts cpub_blocks cpub_characters cpub_emails cpub_local_auth cpub_profiles cpub_users"],
      "cpub.deps.clean": ["deps.clean pointers cpub_accounts cpub_blocks cpub_characters cpub_emails cpub_local_auth cpub_profiles cpub_users --build"],
      "cpub.deps": ["cpub.deps.update", "cpub.deps.clean"],
      setup: ["hex.setup", "rebar.setup", "deps.get", "cpub.deps.clean", "ecto.setup", "js.deps.get"],
      updates: ["deps.get", "cpub.deps.clean", "ecto.migrate", "js.deps.get"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

end
