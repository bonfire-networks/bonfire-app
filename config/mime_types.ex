defmodule Bonfire.Files.MimeTypes do
  # NOTE: this file is here just as a fallback and is intended to get overridden by bonfire_files extension

  def allowed_media,
    do:
      Map.merge(image_media(), video_media())
      |> Map.merge(extra_media())

  def supported_media,
    do:
      allowed_media()
      |> Map.merge(extra_known_types())

  # TODO: how can we make these editable or at least extensible with ENV vars?

  # NOTE: first extension will be considered canonical

  def image_media,
    do: %{
      "image/png" => ["png"],
      "image/apng" => ["apng"],
      "image/jpeg" => ["jpg", "jpeg"],
      "image/gif" => ["gif"],
      "image/svg+xml" => ["svg"],
      "image/webp" => ["webp"]
      # "image/tiff"=> "tiff"

    }

  def video_media,
    do: %{
      "video/mp4" => ["mp4", "mp4v", "mpg4"],
      "video/mpeg" => ["mpeg", "m1v", "m2v", "mpa", "mpe", "mpg"],
      "video/ogg" => ["ogg", "ogv"],
      "video/x-matroska" => ["mkv"],
      "application/x-matroska" => ["mkv"],
      "video/webm" => ["webm"],
      "video/3gpp" => ["3gp"],
      "video/3gpp2" => ["3g2"],
      "video/x-msvideo" => ["avi"],
      "video/quicktime" => ["mov", "qt"]

    }

  def extra_media,
    do: %{
      # docs
      "text/plain" => ["txt", "text", "log", "asc"],
      "text/markdown" => ["md", "mkd", "markdown", "livemd"],
      "text/csv" => ["csv"],
      "text/tab-separated-values" => ["tsv"],
      "application/pdf" => ["pdf"],

      # PIM
      "text/x-vcard" => ["vcf"],
      "application/ics" => ["vcs", "ics"],

      # ebooks
      "application/epub+zip" => ["epub"],
      "application/x-mobipocket-ebook" => ["prc", "mobi"],

      # audio
      "audio/mp3" => ["mp3"],
      "audio/mpeg" => ["mpa", "mp2"],
      "audio/m4a" => ["m4a"],
      "audio/mp4" => ["m4a", "mp4"],
      "audio/x-m4a" => ["m4a"],
      "audio/aac" => ["aac"],
      "audio/ogg" => ["ogg", "oga"],
      "audio/wav" => ["wav"],
      "audio/webm" => ["webm"],
      "audio/opus" => ["opus"],
      "audio/flac" => ["flac"],

         
      # feeds
      "application/atom+xml" => ["atom+xml"],
      "application/rss+xml" => ["rss+xml"],

      # json
      "application/json" => ["json"],
      "application/activity+json" => ["activity+json"],
      "application/ld+json" => ["ld+json"],
      "application/jrd+json" => ["jrd+json"]
    }


  # types we want the server to know about but not necessarily allow uploads for
  def extra_known_types, 
    do: %{
      "image/tiff"=> ["tiff"],

      # archives
           "application/x-tar" => ["tar"],
           "application/x-bzip" => ["bzip"],
           "application/x-bzip2" => ["bzip2"],
           "application/gzip" => ["gz", "gzip"],
           "application/zip" => ["zip"],
           "application/vnd.rar" =>  ["rar"],
           "application/x-7z-compressed" => ["7z"],
       "application/x-bzip2" => ["bzip2"],

# code
           "text/swiftui" => ["swiftui"],
           "text/jetpack" => ["jetpack"],
           "text/styles" => ["styles"],

           # docs
           "application/rtf" => ["rtf"],
                 "application/msword"=> ["doc", "dot"],
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"=> ["docx"],
      "application/vnd.ms-excel"=> ["xls"],
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"=> ["xlsx"],
      "application/vnd.oasis.opendocument.presentation"=> ["odp"],
      "application/vnd.oasis.opendocument.spreadsheet"=> ["ods"],
      "application/vnd.oasis.opendocument.text"=> ["odt"],


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
