#!/bin/sh

DEPS=${1} 

for dep in $DEPS ; do
	printf "Install JS deps from extension %s... " "$dep"

	if cd "forks/$dep/assets" 2>/dev/null ; then
		yarn
		cd ../../../
	fi

	if cd "deps/$dep/assets" 2>/dev/null ; then
		yarn
		cd ../../../
	else
		printf "The extension %s is not available\n" "$dep"
	fi
done