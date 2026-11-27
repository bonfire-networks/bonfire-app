#!/bin/sh

dnf update -q -y

# deps available in default UBI9 repos
dnf install -q -y --setopt=install_weak_deps=False \
  git tar unzip wget file bash \
  ca-certificates gnupg openssl \
  tzdata gettext \
  poppler-utils

# media processing tools - require EPEL/RPM Fusion, install if available
dnf install -q -y ImageMagick || true
dnf install -q -y ffmpeg ffmpegthumbnailer || true
dnf install -q -y vips-tools || true
# HEIC, HEIF and AVIF uploads are converted to WebP with these
dnf install -q -y vips-heif || true
dnf install -q -y ImageMagick-heic || true
dnf install -q -y gifsicle || true
dnf install -q -y libwebp-tools || true
