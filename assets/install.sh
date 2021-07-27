#!/bin/bash 

SCRIPT_DIR=`dirname "$0"`
DIR="${1:-$SCRIPT_DIR}" 

echo "Install JS deps from $DIR"
cd $DIR && pnpm install
