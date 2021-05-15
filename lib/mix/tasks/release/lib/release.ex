defmodule Releaser.VersionUtils do
  @doc """
  Some utilities to get and set version numbers in the `mix.exs` file
  and to programatically transform version numbers.
  Maybe the `bump_*` functions should be in the standard library?
  This script doesn't support pre-release versions or versions with build information.
  """
  @version_line_regex ~r/(\n\s*version:\s+")([^\n]+)(",)/

  def bump_major(%Version{} = version) do
    %{version | major: version.major + 1, minor: 0, patch: 0}
  end

  def bump_minor(%Version{} = version) do
    %{version | minor: version.minor + 1, patch: 0}
  end

  def bump_patch(%Version{} = version) do
    %{version | patch: version.patch + 1}
  end

  def bump_pre(%Version{} = version, pre_label) do
    IO.inspect(old_pre: version.pre)
    new_pre = if is_list(version.pre) and List.first(version.pre) == pre_label do
      [pre_label, List.last(version.pre) + 1]
    else
      [pre_label, 1]
    end
    %{version | pre: new_pre}
  end

  def version_to_string(%Version{major: major, minor: minor, patch: patch, pre: pre}) when is_list(pre) and length(pre)>0 do
    "#{major}.#{minor}.#{patch}-"<>Enum.join(pre, ".")
  end
  def version_to_string(%Version{major: major, minor: minor, patch: patch}) do
    "#{major}.#{minor}.#{patch}"
  end

  def get_version(mix_path \\ ".") do
    version = if Code.ensure_loaded?(Mix.Project) do
      Mix.Project.config()[:version]
    else
      contents = File.read!(mix_path<>"/mix.exs")
      Regex.run(@version_line_regex, contents) |> Enum.fetch!(2)
    end |> IO.inspect
    Version.parse!(version)
  end

  def set_version(version, mix_path \\ ".") do
    contents = File.read!(mix_path<>"/mix.exs")
    version_string = version_to_string(version)

    replaced =
      Regex.replace(@version_line_regex, contents, fn _, pre, _version, post ->
        "#{pre}#{version_string}#{post}"
      end)

    File.write!(mix_path<>"/mix.exs", replaced)
  end

  def update_version(%Version{} = version, "major"), do: bump_major(version)
  def update_version(%Version{} = version, "minor"), do: bump_minor(version)
  def update_version(%Version{} = version, "patch"), do: bump_patch(version)
  def update_version(%Version{} = version, "alpha"=pre_label), do: bump_pre(version, pre_label)
  def update_version(%Version{} = version, "beta"=pre_label), do: bump_pre(version, pre_label)
  def update_version(%Version{} = _version, type), do: raise("Invalid version type: #{type}")
end


defmodule Releaser.Git do
  @doc """
  This module contains some git-specific functionality
  """
  alias Releaser.VersionUtils

  def add_commit_and_tag(version) do
    version_string = VersionUtils.version_to_string(version)
    Mix.Shell.IO.cmd("git add .", [])
    Mix.Shell.IO.cmd(~s'git commit -m "Bumped version number"')
    Mix.Shell.IO.cmd(~s'git tag -a v#{version_string} -m "Version #{version_string}"')
  end
end

defmodule Releaser.Tests do
  def run_tests!() do
    error_code = Mix.Shell.IO.cmd("mix test", [])

    if error_code != 0 do
      raise "This version can't be released because tests are failing."
    end

    :ok
  end
end

defmodule Releaser.Publish do
  def publish!() do
    error_code = Mix.Shell.IO.cmd("mix hex.publish", [])

    if error_code != 0 do
      raise "Couldn't publish package on hex."
    end

    :ok
  end
end

defmodule Mix.Tasks.Bonfire.Release do
  alias Releaser.VersionUtils
  alias Releaser.Git
  alias Releaser.Tests
  alias Releaser.Publish

  def main(args) do # for running as escript
    run(args)
  end

  def run(args) do # when running as Mix task

    mix_path = if is_list(args) and length(args)>0, do: List.first(args), else: "."

    release_type = if is_list(args) and length(args)>1, do: List.last(args), else: "alpha" # TODO make the default configurable

    IO.inspect(release_type: release_type)

    # Run the tests before generating the release.
    # If any test fails, stop.
    # Tests.run_tests!()

    # Get the current version from the mix.exs file.
    old_version = VersionUtils.get_version(mix_path)
    IO.inspect(old_version: old_version)

    new_version = VersionUtils.update_version(old_version, release_type)
    IO.inspect(new_version: new_version |> VersionUtils.version_to_string())

    # Set a new version on the mix.exs file
    VersionUtils.set_version(new_version, mix_path)

    # Commit the changes and ad a new 'v*.*.*' tag
    # Git.add_commit_and_tag(new_version)

    # Try to publish the package on hex.
    # If this fails, we don't want to run all the code above,
    # so you should run `mix hex.publish" again manually to try to solve the problem
    # Publish.publish!()
  end
end
