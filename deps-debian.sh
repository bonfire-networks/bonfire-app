#!/bin/sh

# NOTE: HEIC, HEIF and AVIF uploads are converted to WebP by libvips, whose package here already depends on libheif and its decoders

# root in a container needs no `sudo` (and may not have it), anyone else does (eg. the GitHub runners)
SUDO=""
if [ "$(id -u)" != "0" ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

$SUDO apt-get update -q -y

# deps
$SUDO apt-get install -q -y --no-install-recommends git tar unzip curl wget file mailcap bash \
ca-certificates openssh-client libgcrypt20-dev libssl-dev gnupg \
tzdata gettext \
imagemagick libvips-tools gifsicle webp poppler-utils ffmpegthumbnailer ffmpeg
