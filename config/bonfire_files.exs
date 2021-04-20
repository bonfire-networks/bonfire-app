use Mix.Config

# where do you want to store files? supports local storage, s3-compatible services, and more
# see https://hexdocs.pm/waffle/Waffle.html#module-setup-a-storage-provider
config :waffle,
  storage: Waffle.Storage.Local,
  asset_host: "/" # or {:system, "ASSET_HOST"}

image_media_types = ["image/png", "image/jpeg", "image/gif", "image/svg+xml", "image/tiff"]

all_media_types = image_media_types ++ [
  "text/plain",
  # doc
  "text/csv",
  "application/pdf",
  "application/rtf",
  "application/msword",
  "application/vnd.ms-excel",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "application/vnd.oasis.opendocument.presentation",
  "application/vnd.oasis.opendocument.spreadsheet",
  "application/vnd.oasis.opendocument.text",
  "application/epub+zip",
  # archives
  "application/x-tar",
  "application/x-bzip",
  "application/x-bzip2",
  "application/gzip",
  "application/zip",
  "application/rar",
  "application/x-7z-compressed",
  # audio
  "audio/mpeg",
  "audio/ogg",
  "audio/wav",
  "audio/webm",
  "audio/opus",
  # video
  "video/mp4",
  "video/mpeg",
  "video/ogg",
  "video/webm",
]

config :bonfire, Bonfire.Files.IconUploader, allowed_media_types: image_media_types
config :bonfire, Bonfire.Files.ImageUploader, allowed_media_types: image_media_types
config :bonfire, Bonfire.Files.DocumentUploader, allowed_media_types: all_media_types
