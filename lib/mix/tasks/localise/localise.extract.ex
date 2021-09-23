defmodule Mix.Tasks.Bonfire.Localise.Extract do
  use Mix.Task
  @recursive true

  @shortdoc "Extracts translations from source code"

  @moduledoc """
  Extracts translations by recompiling the Elixir source code.

      mix gettext.extract [OPTIONS]

  Translations are extracted into POT (Portable Object Template) files (with a
  `.pot` extension). The location of these files is determined by the `:otp_app`
  and `:priv` options given by Gettext modules when they call `use Gettext`. One
  POT file is generated for each translation domain.

  It is possible to give the `--merge` option to perform merging
  for every Gettext backend updated during merge:

      mix gettext.extract --merge

  All other options passed to `gettext.extract` are forwarded to the
  `gettext.merge` task (`Mix.Tasks.Gettext.Merge`), which is called internally
  by this task. For example:

      mix gettext.extract --merge --no-fuzzy

  """

  @switches [merge: :boolean]

  def run(args, app \\ :bonfire_common) do
    Application.ensure_all_started(:gettext)
    _ = Mix.Project.get!()
    mix_config = Mix.Project.config()
    {opts, _} = OptionParser.parse!(args, switches: @switches)
    pot_files = extract(app || mix_config[:app], mix_config[:gettext] || []) #|> IO.inspect(label: "extracted")

    for {path, contents} <- pot_files do
      File.mkdir_p!(Path.dirname(path))
      File.write!(path, contents)
      Mix.shell().info("Extracted #{Path.relative_to_cwd(path)}")
    end

    if opts[:merge] do
      run_merge(pot_files, args)
    end

    :ok
  end

  defp extract(app, gettext_config) do
    Gettext.Extractor.enable()
    force_compile()
    Gettext.Extractor.pot_files(
      app, # |> IO.inspect(label: "app"),
      gettext_config # |> IO.inspect(label: "config")
    )
  after
    Gettext.Extractor.disable()
  end

  defp force_compile do
    Mix.Tasks.Compile.Elixir.manifests()
    # ++ (Mix.Project.build_path<>"/lib/bonfire_*/.mix/compile.elixir" |> IO.inspect |> Path.wildcard(match_dot: true))
    # ["forks/bonfire_common/lib/web/gettext.ex" |> Path.expand(File.cwd!)]
    #|> IO.inspect(label: "recompile")
    |> Enum.map(&make_old_if_exists/1)

    (["--force"] ++ Bonfire.MixProject.deps_to_localise()) #|> IO.inspect
    |> Mix.Tasks.Bonfire.Dep.Compile.run()

    # If "compile" was never called, the reenabling is a no-op and
    # "compile.elixir" is a no-op as well (because it wasn't reenabled after
    # running "compile"). If "compile" was already called, then running
    # "compile" is a no-op and running "compile.elixir" will work because we
    # manually reenabled it.
    Mix.Task.reenable("compile.elixir")
    Mix.Task.run("compile")
    Mix.Task.run("compile.elixir")
  end

  defp make_old_if_exists(path) do
    :file.change_time(path, {{2000, 1, 1}, {0, 0, 0}})
  end

  defp run_merge(pot_files, argv) do
    pot_files
    |> Enum.map(fn {path, _} -> Path.dirname(path) end)
    |> Enum.uniq()
    |> Task.async_stream(&Mix.Tasks.Gettext.Merge.run([&1 | argv]), ordered: false)
    |> Stream.run()
  end
end
