#!/bin/sh

# any extensions/deps with a package.json in their /assets directory
DEPS=''

chmod +x ./priv/deps.js.sh
./priv/deps.js.sh "$DEPS"