#!/bin/bash

# runtime deps
chmod +x ./deps-alpine.sh
./deps-alpine.sh

apk add --update --no-cache just elixir tar file mailcap make build-base libc-dev sqlite npm yarn
# rust cargo gcc
