#!/bin/bash

apt-get update -q -y

# runtime deps
chmod +x ./deps-debian.sh
./deps-debian.sh

# dev deps
apt-get install -q -y --no-install-recommends npm sqlite3 libssl3 libatomic1 autoconf dpkg-dev libncurses-dev unixodbc-dev libssl-dev libsctp-dev libodbc1 libsctp1 make gcc g++ cmake
# includes build tools needed for mise to build erlang ^
# rustc cargo g++ 

# tools
# NOTE: using mise because bullseye elixir version is too old
curl https://mise.run | sh

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
echo "export PATH=\"\$HOME/.local/share/mise/shims:\$HOME/.local/bin:\$PATH\"" >> ~/.bash_profile

mise plugin-add erlang 
mise plugin-add elixir 
mise plugin-add just

mise install || echo "error during install of tools with mise"

# `mise install` above is allowed to fail, so don't assume it gave us a node. Prefer mise's (pinned in .tool-versions, first on PATH via the shims), and fall back to the apt one installed with the dev deps, so a mise outage degrades the build to an older node instead of breaking it outright.
node -v || apt-get install -q -y --no-install-recommends nodejs npm || echo "no node available, JS deps will fail"

# AFTER mise, so this binds to the node pinned in .tool-versions rather than to whatever node apt happens to ship. corepack, not yarn: it reads each extension's `packageManager` pin and fetches that yarn. `npm install -g yarn` would give us 1.22.x, which js-deps-get.sh refuses to run.
npm install -g corepack && corepack enable

# npm puts its globals in the prefix of the node that ran it. For mise's node that's inside the mise install dir, which has no shim until we ask for one, so without this `yarn` is not on PATH for later steps.
mise reshim || true

node -v && which yarn && yarn -v || echo "yarn is not usable"

# FYI: uses .tool-versions instead of the below
# which erl || (mise install erlang latest && asdf global erlang latest)
# elixir -v || (asdf install elixir latest && asdf global elixir latest) #|| apt-get install -y elixir
# just --version || (asdf install just latest && asdf global just latest) || cargo install just #|| apt-get install -y just 

