apt-get update -q -y
apt-get install -q -y git tar file gcc sqlite3 yarnpkg mailcap ca-certificates libssl-dev tzdata gettext curl rustc cargo wget

bash -ci "$(wget -qO - 'https://shlink.makedeb.org/install')"
git clone 'https://mpr.makedeb.org/just' && cd just && makedeb -si

echo "deb http://packages.erlang-solutions.com/debian bullseye contrib" >> /etc/apt/sources.list
wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && apt-key add erlang_solutions.asc
apt-get update && apt-get install -y elixir
elixir -v
