#!/bin/sh
set -euo pipefail

export MIX_TARGET=app
export ELIXIRKIT_APP_NAME=Bonfire
export ELIXIRKIT_PROJECT_DIR=$PWD/../../..
export ELIXIRKIT_RELEASE_NAME=bonfire

export ELIXIRKIT_MIX_PATH=../../../deps/elixirkit/elixirkit
# ^ path also needs to be set in Package.swift

. $ELIXIRKIT_MIX_PATH/elixirkit_swift/Scripts/build_macos_app.sh
