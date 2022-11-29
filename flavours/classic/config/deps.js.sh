#!/bin/sh

# any extensions/deps with a package.json in their /assets directory
# space separated
DEPS='iconify_ex bonfire_ui_common bonfire_editor_quill'
# bonfire_editor_ck

chmod +x ./js-deps-get.sh
./js-deps-get.sh "$DEPS" $@