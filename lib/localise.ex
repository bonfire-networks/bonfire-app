defmodule Bonfire.Localise do
  @moduledoc """
  Runs at compile-time to include dynamic strings (like verb names and object types) in localisation string extraction.
  """

  use Bonfire.Common.Localise

  Bonfire.Social.Activities.all_verb_names_extra()
  |> IO.inspect(label: "Making all verb names localisable")
  |> localise_strings(Bonfire.Social.Activities)

  Bonfire.Common.Types.all_object_type_names()
  |> IO.inspect(label: "Making all object type names localisable")
  |> localise_strings(Bonfire.Common.Types)

  l "timeline"
  l "posts"
  l "boosts"

  # for {item, _item} <- Bonfire.Common.Config.get([:ui, :profile, :navigation], [timeline: "timeline"])
  #                   |> IO.inspect(label: "Making profile tab names localisable") do
  #   # localise_string("#{item}")
  #   dgettext("bonfire", "#{item}", [])
  # end
end
