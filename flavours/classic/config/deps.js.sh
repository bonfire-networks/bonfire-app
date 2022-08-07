#!/bin/sh

# any extensions/deps with a package.json in their /assets directory
# space seperated
DEPS='iconify_ex bonfire_ui_common bonfire_editor_ck bonfire_editor_quill'

chmod +x ./assets/install_extensions.sh
./assets/install_extensions.sh "$DEPS" $@