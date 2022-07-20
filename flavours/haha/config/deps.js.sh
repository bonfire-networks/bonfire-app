#!/bin/sh

# any extensions/deps with a package.json in their /assets directory
DEPS=''

chmod +x ./assets/install_extensions.sh
./assets/install_extensions.sh "$DEPS" $@