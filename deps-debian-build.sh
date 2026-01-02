#!/bin/bash

apt-get update -q -y

# runtime deps
chmod +x ./deps-debian.sh
./deps-debian.sh

# dev deps
apt-get install -q -y --no-install-recommends npm sqlite3 libssl3 libatomic1 autoconf dpkg-dev libncurses-dev unixodbc-dev libssl-dev libsctp-dev libodbc1 libsctp1 make gcc g++ cmake
# includes build tools needed for mise to build erlang ^
# rustc cargo g++ 

npm install -g corepack && corepack enable || npm install -g yarn

# tools
# NOTE: using mise because bullseye elixir version is too old
curl https://mise.run | sh

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
echo "export PATH=\"\$HOME/.local/share/mise/shims:\$HOME/.local/bin:\$PATH\"" >> ~/.bash_profile

mise plugin-add erlang 
mise plugin-add elixir 
mise plugin-add just

mise install || echo "error during install of tools with mise"

# FYI: uses .tool-versions instead of the below
# which erl || (mise install erlang latest && asdf global erlang latest)
# elixir -v || (asdf install elixir latest && asdf global elixir latest) #|| apt-get install -y elixir
# just --version || (asdf install just latest && asdf global just latest) || cargo install just #|| apt-get install -y just 

