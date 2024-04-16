#!/bin/bash

# runtime deps
chmod +x ./deps-alpine.sh
./deps-alpine.sh

apk add --update --no-cache just elixir tar file mailcap make build-base gcc libc-dev rust cargo sqlite npm yarn

