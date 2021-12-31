#!/bin/sh

# any extensions/deps with a package.json in their /assets directory
DEPS='bonfire_geolocate bonfire_ui_kanban'

chmod +x ./priv/deps.js.sh
./priv/deps.js.sh "$DEPS"