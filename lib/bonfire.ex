defmodule Bonfire do
  @moduledoc false
  # alias Bonfire.Common.Config

  @deps_loaded Bonfire.Common.Extensions.loaded_deps(:nested)
  @deps_tree_flat Bonfire.Common.Extensions.loaded_deps(:tree_flat)

  def deps(opt \\ nil)
  # as loaded at compile time, nested
  def deps(:nested), do: @deps_loaded
  #  as loaded at compile time, flat
  def deps(:tree_flat), do: @deps_tree_flat
  # as defined in the top-level app's mix.exs / deps.hex / etc
  def deps(_), do: Bonfire.Application.config()[:deps]
end
