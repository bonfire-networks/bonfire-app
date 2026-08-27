#!/bin/bash

dnf update -q -y

# runtime deps
chmod +x ./deps-rhel.sh
./deps-rhel.sh

# core build tools (all available in default UBI9 AppStream repo)
dnf install -q -y \
  gcc gcc-c++ make autoconf diffutils \
  openssl-devel ncurses-devel \
  unixODBC-devel unixODBC \
  libatomic \
  sqlite cmake

# optional: SCTP support for Erlang (not critical)
dnf install -q -y lksctp-tools-devel || true

# tools
# NOTE: using mise because ubi9 erlang/elixir and npm versions may be too old
curl https://mise.run | sh

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
echo "export PATH=\"\$HOME/.local/share/mise/shims:\$HOME/.local/bin:\$PATH\"" >> ~/.bash_profile

mise plugin-add erlang
mise plugin-add elixir
mise plugin-add just

mise install || echo "error during install of tools with mise"

# `mise install` above is allowed to fail, so don't assume it gave us a node. Prefer mise's (pinned in .tool-versions, first on PATH via the shims), and fall back to the AppStream one so a mise outage degrades the build to an older node instead of breaking it outright.
node -v || dnf install -q -y nodejs npm || echo "no node available, JS deps will fail"

# using whichever node won above. corepack, not yarn: it reads each extension's `packageManager` pin and fetches that yarn. `npm install -g yarn` would give us 1.22.x, which js-deps-get.sh refuses to run.
npm install -g corepack && corepack enable

# npm puts its globals in the prefix of the node that ran it. For mise's node that's inside the mise install dir, which has no shim until we ask for one, so without this `yarn` is not on PATH for later steps.
mise reshim || true

node -v && which yarn && yarn -v || echo "yarn is not usable"
