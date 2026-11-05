#!/bin/bash

# runtime deps
chmod +x ./deps-alpine.sh
./deps-alpine.sh

# NOTE: we don't install erlang/elixir here because we assume that we're running this script in an environment (eg docker image) that already has these installed
# apk add --update --no-cache elixir erlang

apk add --update --no-cache just tar file mailcap make build-base libc-dev sqlite npm rustup gcc cmake

# Rust from rustup rather than Alpine's `cargo` package, because NIFs built from source (eg. with RUSTLER_BUILD_ALL, or on arm32v7) can need a newer rustc than the Alpine release ships (lumis needs 1.95). Set CARGO_HOME and RUSTUP_HOME, and add $CARGO_HOME/bin to PATH, before running this script so later build steps find cargo.
rustup-init -y --profile minimal --default-toolchain stable --no-modify-path

# corepack, not yarn: it reads each extension's `packageManager` pin and fetches that yarn. `npm install -g yarn` would give us 1.22.x, which js-deps-get.sh refuses to run.
npm install -g corepack && corepack enable
