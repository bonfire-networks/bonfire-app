#!/bin/bash

# runtime deps
chmod +x ./deps-alpine.sh
./deps-alpine.sh

# NOTE: we don't install erlang/elixir here because we assume that we're running this script in an environment (eg docker image) that already has these installed
# apk add --update --no-cache elixir erlang

apk add --update --no-cache just tar file mailcap make build-base libc-dev sqlite npm cargo gcc cmake
# rust 

# corepack, not yarn: it reads each extension's `packageManager` pin and fetches that yarn. `npm install -g yarn` would give us 1.22.x, which js-deps-get.sh refuses to run.
npm install -g corepack && corepack enable
