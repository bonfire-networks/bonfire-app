asdf_dir=/opt/asdf
mkdir -p ${asdf_dir}
export PATH=${asdf_dir}/bin:${asdf_dir}/shims:${PATH}

apt-get update -q -y
apt-get install -q -y git tar file gcc sqlite3 npm mailcap ca-certificates libssl-dev tzdata gettext curl rustc cargo wget gnupg sudo unzip

# Setup makedeb.
# curl -q 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null 
# echo "deb [signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr bullseye" | tee /etc/apt/sources.list.d/prebuilt-mpr.list 

# Elixir
# echo "deb http://packages.erlang-solutions.com/debian bullseye contrib" >> /etc/apt/sources.list
# wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && apt-key add erlang_solutions.asc

git clone https://github.com/asdf-vm/asdf.git ${asdf_dir} --branch v0.11.1
asdf plugin-add erlang && asdf plugin-add elixir && asdf plugin-add just

# Install
apt-get update -q -y
elixir -v || asdf install elixir latest #|| apt-get install -y elixir
just --version || asdf install just latest || cargo install just #|| apt-get install -y just 
npm install --global yarn

elixir -v
just --version
yarn -v
