#!/bin/sh

# add more modules separated by $IFS
DEPS='iconify_ex bonfire_ui_common bonfire_editor_ck bonfire_geolocate'

chmod +x ./js-deps-get.sh
./js-deps-get.sh "$DEPS" $@