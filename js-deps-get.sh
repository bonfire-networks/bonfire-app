#!/bin/sh
# This script is meant to be called by another script defined in each flavour 
# It cycles through a list of extensions (provided in args) and installs their JS deps, if any

DEPS=${1} 
# TOOL="npm install"
TOOL=yarn

command -v $TOOL || (command -v npm && npm -g install $TOOL) || echo "$TOOL is required to install JS deps!"

for dep in $DEPS ; do

	if cd "extensions/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'extensions/$dep' with args '$2'"
		$TOOL $2
		cd ../../../
	fi

	if cd "forks/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'forks/$dep' with args '$2'"
		$TOOL $2
		cd ../../../
	fi

	if cd "deps/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'deps/$dep' with args '$2'"
		$TOOL $2
		cd ../../../
	else
		echo "The extension '$dep' is not available\n"
	fi
done
