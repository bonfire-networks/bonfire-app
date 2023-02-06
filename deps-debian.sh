# NOTE: using asdf because bullseye elixir version is too old

asdf_dir=/opt/asdf
mkdir -p $asdf_dir
export PATH=$asdf_dir/bin:$asdf_dir/shims:$PATH

apt-get update -q -y
apt-get install -q -y git tar file gcc sqlite3 npm mailcap ca-certificates libssl-dev tzdata gettext curl rustc cargo wget gnupg sudo unzip

git clone https://github.com/asdf-vm/asdf.git $asdf_dir --branch v0.11.1
asdf plugin-add erlang && asdf plugin-add elixir && asdf plugin-add just

# Install
apt-get update -q -y
elixir -v || asdf install elixir latest #|| apt-get install -y elixir
just --version || asdf install just latest || cargo install just #|| apt-get install -y just 
npm install --global yarn

elixir -v
just --version
yarn -v

