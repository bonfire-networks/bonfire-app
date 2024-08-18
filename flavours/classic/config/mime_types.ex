defmodule Bonfire.Files.MimeTypes do
  # NOTE: this file is here just as a fallback and is intended to get overridden by bonfire_files extension

  def supported_media,
    do:
      Map.merge(image_media(), video_media())
      |> Map.merge(extra_media())

  # TODO: how can we make these editable or at least extensible with ENV vars?

  # NOTE: first extension will be considered canonical

  def image_media,
    do: %{
      "image/png" => ["png"]
    }

  def video_media, do: %{}

  def extra_media,
    do: %{
      "application/json" => ["json"],
      "application/activity+json" => ["activity+json"],
      "application/ld+json" => ["ld+json"],
      "application/jrd+json" => ["jrd+json"]
    }

  # define which is preferred when more than one
  def unique_extension_for_mime do
    supported_media()
    |> Enum.flat_map(fn {mime, extensions} ->
      extensions
      |> Enum.reverse()
      |> Enum.map(fn ext -> {ext, mime} end)
    end)
    #   |> Enum.uniq_by(fn {x, _} -> x end)
    |> Map.new()
  end
end
