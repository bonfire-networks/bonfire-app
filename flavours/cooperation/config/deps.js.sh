#!/bin/bash 

# any extensions/deps with a package.json in their /assets directory
DEPS="bonfire_geolocate bonfire_ui_kanban"

for dep in $DEPS 
do
 echo "Install JS deps from $dep"
 cd "deps/$dep/assets" && pnpm install && cd ../../../ || echo "Extension $dep not available in deps"
 cd "forks/$dep/assets" && pnpm install && cd ../../../ || echo "Extension $dep not available in forks"
done