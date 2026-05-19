#!/bin/bash

dnf update -q -y

# runtime deps
chmod +x ./deps-rhel.sh
./deps-rhel.sh

# core build tools (all available in default UBI9 AppStream repo)
dnf install -q -y \
  gcc gcc-c++ make autoconf \
  openssl-devel ncurses-devel \
  unixODBC-devel unixODBC \
  nodejs npm \
  sqlite cmake

# optional: SCTP support for Erlang (not critical)
dnf install -q -y lksctp-tools-devel || true

npm install -g corepack && corepack enable || npm install -g yarn

# tools
# NOTE: using mise because ubi9 elixir version may be too old
curl https://mise.run | sh

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
echo "export PATH=\"\$HOME/.local/share/mise/shims:\$HOME/.local/bin:\$PATH\"" >> ~/.bash_profile

mise plugin-add erlang
mise plugin-add elixir
mise plugin-add just

mise install || echo "error during install of tools with mise"
