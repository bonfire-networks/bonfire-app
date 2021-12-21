#!/bin/sh

DEPS=${1} 

for dep in $DEPS ; do
	printf "Install JS deps from '%s'...\n" "$dep"
	if cd "forks/$dep/assets" 2>/dev/null || cd "deps/$dep/assets" 2>/dev/null ; then
		pnpm install
		cd ../../../
	else
		printf "Extension '%s' not available\n" "$dep"
	fi
done