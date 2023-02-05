apt-get update -q -y
apt-get install -q -y git tar file gcc sqlite3 npm mailcap ca-certificates libssl-dev tzdata gettext curl rustc cargo wget gnupg sudo

# Setup makedeb.
curl -q 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null 
echo "deb [signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr bullseye" | tee /etc/apt/sources.list.d/prebuilt-mpr.list 

# Elixir
echo "deb http://packages.erlang-solutions.com/debian bullseye contrib" >> /etc/apt/sources.list
wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && apt-key add erlang_solutions.asc

# Install
apt-get update -q -y
elixir -v || apt-get install -y elixir
apt-get install -y just || cargo install just
npm install --global yarn

elixir -v
just --version
yarn -v
