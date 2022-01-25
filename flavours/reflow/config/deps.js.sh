#!/bin/sh

# add more modules separated by $IFS
DEPS='bonfire_geolocate'

chmod +x ./priv/deps.js.sh
./priv/deps.js.sh "$DEPS"