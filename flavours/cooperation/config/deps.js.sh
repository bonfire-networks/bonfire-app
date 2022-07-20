#!/bin/sh

# Add any extensions/deps with a package.json in their /assets directory here
# NOTE: any LV Hooks should also be added to ./deps_hooks.js
# TODO: make this more configurable? ie. autogenerate from active extensions with JS assets

DEPS='bonfire_ui_common bonfire_editor_ck bonfire_editor_quill bonfire_geolocate bonfire_ui_kanban'

chmod +x ./assets/install_extensions.sh
./assets/install_extensions.sh "$DEPS" $@
