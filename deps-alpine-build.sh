#!/bin/bash

# runtime deps
chmod +x ./deps-alpine.sh
./deps-alpine.sh

# NOTE: we don't install erlang/elixir here because we assume that we're running this script in an environment (eg docker image) that already has these installed
# apk add --update --no-cache elixir erlang

apk add --update --no-cache just tar file mailcap make build-base libc-dev sqlite npm cargo gcc cmake
# rust 

npm install -g corepack
corepack enable
