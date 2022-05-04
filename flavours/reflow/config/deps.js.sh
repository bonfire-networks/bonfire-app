#!/bin/sh

# add more modules separated by $IFS
DEPS='bonfire_ui_common bonfire_ui_social bonfire_editor_ck bonfire_geolocate'

chmod +x ./priv/deps.js.sh
./priv/deps.js.sh "$DEPS"