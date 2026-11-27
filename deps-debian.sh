#!/bin/sh

# NOTE: HEIC, HEIF and AVIF uploads are converted to WebP by libvips, whose package here depends on libheif and an AV1 decoder (see the HEVC one, for HEIC, below)

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

# HEIC needs libheif's HEVC decoder, which libvips' package doesn't pull in (libheif only depends on an AV1 decoder, so AVIF works without it) and which older releases bundle in libheif itself (no such package there, hence the `|| true`)
$SUDO apt-get install -q -y --no-install-recommends libheif-plugin-libde265 || true
