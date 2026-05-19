#!/bin/bash

dnf update -q -y

# runtime deps
chmod +x ./deps-rhel.sh
./deps-rhel.sh

# Enable EPEL for extra packages
dnf install -q -y epel-release || true

# dev deps (build tools needed for mise to build erlang)
dnf install -q -y --setopt=install_weak_deps=False \
  npm sqlite gcc gcc-c++ make cmake autoconf \
  openssl-devel ncurses-devel unixODBC-devel \
  lksctp-tools-devel unixODBC

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
