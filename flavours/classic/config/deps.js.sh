#!/bin/sh

# SPDX-FileCopyrightText: 2023 Bonfire contributors <https://github.com/bonfire-networks/bonfire-app/graphs/contributors>
#
# SPDX-License-Identifier: AGPL-3.0-only

# Add any extensions/deps with a package.json in their /assets directory here
# NOTE: any LV Hooks should also be added to ./deps_hooks.js
# TODO: make this more configurable? ie. autogenerate from active extensions with JS assets

DEPS='iconify_ex bonfire_ui_common bonfire_editor_milkdown'
# bonfire_editor_quill bonfire_editor_ck

chmod +x ./js-deps-get.sh
./js-deps-get.sh "$DEPS" $@
