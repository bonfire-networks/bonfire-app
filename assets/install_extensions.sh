#!/bin/sh
# This script is meant to be called by another script defined in each flavour 
# It cycles through a list of extensions (provided in args) and installs their JS deps, if any

DEPS=${1} 

for dep in $DEPS ; do
	echo "Install JS deps from extension '$dep' with args '$2'"

	if cd "forks/$dep/assets" 2>/dev/null ; then
		yarn $2
		cd ../../../
	fi

	if cd "deps/$dep/assets" 2>/dev/null ; then
		yarn $2
		cd ../../../
	else
		echo "The extension '$dep' is not available\n"
	fi
done