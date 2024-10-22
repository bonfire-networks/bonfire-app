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
      "application/jrd+json" => ["jrd+json"],
      "application/json" => ["json"],
      "application/activity+json" => ["activity+json"],
      "application/ld+json" => ["ld+json"],
      "application/jrd+json" => ["jrd+json"],
      "application/x-tar" => ["tar"],
      "application/x-bzip" => ["bzip"],
      "application/x-bzip2" => ["bzip2"],
      "application/gzip" => ["gz", "gzip"],
      "application/zip" => ["zip"],
      "application/vnd.rar" => ["rar"],
      "application/x-7z-compressed" => ["7z"],
      "text/plain" => ["txt", "text", "log", "asc"],
      "application/gzip" => ["gz", "gzip"],
      "text/swiftui" => ["swiftui"],
      "text/jetpack" => ["jetpack"],
      "video/mpeg" => ["mpeg", "m1v", "m2v", "mpa", "mpe", "mpg"],
      "audio/wav" => ["wav"],
      "video/3gpp" => ["3gp"],
      "application/x-mobipocket-ebook" => ["prc", "mobi"],
      "application/x-bzip2" => ["bzip2"],
      "text/csv" => ["csv"],
      "image/svg+xml" => ["svg"],
      "audio/mpeg" => ["mpa", "mp2"],
      "application/epub+zip" => ["epub"],
      "application/x-matroska" => ["mkv"],
      "application/jrd+json" => ["jrd+json"],
      "image/webp" => ["webp"],
      "application/json" => ["json"],
      "image/gif" => ["gif"],
      "text/tab-separated-values" => ["tsv"],
      "image/png" => ["png"],
      "audio/webm" => ["webm"],
      "audio/opus" => ["opus"],
      "application/rtf" => ["rtf"],
      "application/ld+json" => ["ld+json"],
      "video/webm" => ["webm"],
      "application/ics" => ["vcs", "ics"],
      "video/mp4" => ["mp4", "mp4v", "mpg4"],
      "audio/mp4" => ["m4a", "mp4"],
      "application/x-7z-compressed" => ["7z"],
      "audio/mp3" => ["mp3"],
      "text/markdown" => ["md", "mkd", "markdown", "livemd"],
      "audio/flac" => ["flac"],
      "application/activity+json" => ["activity+json"],
      "audio/m4a" => ["m4a"],
      "image/jpeg" => ["jpg", "jpeg"],
      "audio/x-m4a" => ["m4a"],
      "video/3gpp2" => ["3g2"],
      "application/vnd.rar" => ["rar"],
      "video/x-msvideo" => ["avi"],
      "application/pdf" => ["pdf"],
      "audio/ogg" => ["ogg", "oga"],
      "text/plain" => ["txt", "text", "log", "asc"],
      "text/styles" => ["styles"],
      "application/zip" => ["zip"],
      "video/quicktime" => ["mov", "qt"],
      "audio/aac" => ["aac"],
      "application/x-bzip" => ["bzip"],
      "video/x-matroska" => ["mkv"],
      "text/x-vcard" => ["vcf"],
      "video/ogg" => ["ogg", "ogv"],
      "image/apng" => ["apng"],
      "application/x-tar" => ["tar"]
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
