#!/bin/sh

# any extensions/deps with a package.json in their /assets directory
DEPS='iconify_ex bonfire_ui_common bonfire_editor_ck bonfire_editor_quill'

chmod +x ./js-deps-get.sh
./js-deps-get.sh "$DEPS" $@