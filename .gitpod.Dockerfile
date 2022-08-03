FROM gitpod/workspace-postgresql

RUN sudo apt-get update \
 && sudo apt-get install -y \
    yarn \
 && sudo rm -rf /var/lib/apt/lists/*

RUN brew install just elixir 
