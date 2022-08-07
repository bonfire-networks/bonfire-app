#!/bin/bash 

# any extensions/deps with a package.json in their /assets directory
DEPS='iconify_ex bonfire_ui_common bonfire_editor_ck bonfire_geolocate'

chmod +x ./assets/install_extensions.sh
./assets/install_extensions.sh "$DEPS" $@