#!/bin/sh

# any extensions/deps with a package.json in their /assets directory
# space seperated
DEPS='bonfire_ui_common bonfire_editor_ck bonfire_editor_quill'

chmod +x ./priv/deps.js.sh
./priv/deps.js.sh "$DEPS"