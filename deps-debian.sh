#!/bin/bash
# NOTE: using asdf because bullseye elixir version is too old

asdf_dir=/opt/asdf
mkdir -p $asdf_dir

apt-get update -q -y
apt-get install -q -y --no-install-recommends git tar file gcc sqlite3 npm mailcap ca-certificates libssl-dev tzdata gettext curl rustc cargo wget gnupg sudo unzip

git clone https://github.com/asdf-vm/asdf.git $asdf_dir --branch v0.11.1
. "$asdf_dir/asdf.sh"
asdf plugin-add erlang && asdf plugin-add elixir && asdf plugin-add just

# Install
apt-get install -q -y --no-install-recommends autoconf dpkg-dev gcc g++ make libncurses-dev unixodbc-dev libssl-dev libsctp-dev libodbc1 libssl1.1 libsctp1 
# TODO: use .tool-versions instead of latest
which erl || (asdf install erlang latest && asdf global erlang latest)
elixir -v || (asdf install elixir latest && asdf global elixir latest) #|| apt-get install -y elixir
just --version || (asdf install just latest && asdf global just latest) || cargo install just #|| apt-get install -y just 
npm install --global yarn

echo $PATH
ls -la $asdf_dir && ls -la $asdf_dir/bin && ls -la /github/home/.asdf/shims
elixir -v
just --version
yarn -v

