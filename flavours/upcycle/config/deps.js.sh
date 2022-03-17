#!/bin/bash 

# any extensions/deps with a package.json in their /assets directory
DEPS='bonfire_common bonfire_ui_social bonfire_editor_ck bonfire_geolocate'

chmod +x ./priv/deps.js.sh
./priv/deps.js.sh "$DEPS"