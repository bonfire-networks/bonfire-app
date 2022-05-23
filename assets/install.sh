#!/bin/sh 

SCRIPT_DIR=`dirname "$0"`
DIR="${1:-$SCRIPT_DIR}" 

printf "Install the app's main JS deps from $DIR... "

yarn -v || npm -g install yarn

cd $DIR && yarn
