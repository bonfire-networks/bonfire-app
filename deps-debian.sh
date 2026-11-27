#!/bin/sh

# NOTE: HEIC, HEIF and AVIF uploads are converted to WebP by libvips, whose package here already depends on libheif and its decoders

apt-get update -q -y

# deps
apt-get install -q -y --no-install-recommends git tar unzip curl wget file mailcap bash \
ca-certificates openssh-client libgcrypt20-dev libssl-dev gnupg \
tzdata gettext \
imagemagick libvips-tools gifsicle webp poppler-utils ffmpegthumbnailer ffmpeg
