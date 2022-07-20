#!/bin/sh

# add more modules separated by $IFS
DEPS='bonfire_ui_common bonfire_editor_ck bonfire_geolocate'

chmod +x ./assets/install_extensions.sh
./assets/install_extensions.sh "$DEPS" $@