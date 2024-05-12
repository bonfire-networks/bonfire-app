#!/bin/sh

apt-get update -q -y

# deps
apt-get install -q -y --no-install-recommends git tar unzip curl wget file mailcap bash \
ca-certificates openssh-client libgcrypt20-dev libssl-dev gnupg \
tzdata gettext \
imagemagick libvips-tools poppler-utils ffmpegthumbnailer ffmpeg
