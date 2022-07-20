#!/bin/sh 
# This script installs the main app's JS deps

SCRIPT_DIR=`dirname "$0"`

echo "Install the app's main JS deps from dir '$SCRIPT_DIR' with args '$@'\n"

yarn -v || npm -g install yarn

cd $DIR && yarn $@
