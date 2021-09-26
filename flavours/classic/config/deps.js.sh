#!/bin/bash 

DEPS="bonfire_geolocate" 

for dep in $DEPS 
do
 echo "Install JS deps from $dep"
 cd "forks/$dep/assets" && pnpm install || cd "deps/$dep/assets" && pnpm install || echo "Extension $dep not available"
done