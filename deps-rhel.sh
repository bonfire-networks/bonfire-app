#!/bin/sh

dnf update -q -y

# deps
dnf install -q -y --setopt=install_weak_deps=False \
  git tar unzip curl wget file bash \
  ca-certificates gnupg openssl-devel \
  tzdata gettext \
  ImageMagick libvips-tools poppler-utils ffmpeg
