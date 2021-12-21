#!/bin/sh

# any extensions/deps with a package.json in their /assets directory
DEPS='bonfire_geolocate bonfire_ui_kanban'

./priv/deps.js.sh "$DEPS"