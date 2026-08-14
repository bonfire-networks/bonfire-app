#!/bin/sh
# This script is meant to be called by another script defined in each flavour 
# It cycles through a list of extensions (provided in args) and installs their JS deps, if any

DEPS=${1} 
# TOOL="npm install"
TOOL=yarn

command -v $TOOL || (command -v npm && npm -g install $TOOL) || echo "$TOOL is required to install JS deps!"

# With no args we install. With a script name, only run it where package.json defines it — so a
# shared loop (eg. `just js-ext-build`) can ask every extension to build its own bundles without
# erroring on the ones that have none.
case "${2:-}" in
	watch*) PARALLEL=1 ;;
	*) PARALLEL="" ;;
esac

run_tool() {
	if [ -z "$2" ]; then
		$1 || return $?
	elif ! node -e "process.exit((require('./package.json').scripts||{})['$2'] ? 0 : 1)" 2>/dev/null ; then
		echo "  (no '$2' script here, skipping)"
	elif [ -n "$PARALLEL" ]; then
		$1 $2 &
	else
		$1 $2 || return $?
	fi
}

for dep in $DEPS ; do

	if cd "extensions/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'extensions/$dep' with args '$2'"
		run_tool $TOOL "$2"
		cd ../../../
	else
		if cd "forks/$dep/assets" 2>/dev/null ; then
			echo "Install JS deps from extension 'forks/$dep' with args '$2'"
			run_tool $TOOL "$2"
			cd ../../../
		else
			# TODO: we should only attempt to install from `deps/*` if the extension is not cloned in `extensions/*` or `forks/*`, but this risks the JS deps not being available if we later switch to using the upstream dep, so maybe we should read WITH_FORKS env for this
			echo "Extension '$dep' is not cloned, trying to install from 'deps/$dep'"
		fi
	fi

	
	if cd "deps/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'deps/$dep' with args '$2'"
		run_tool $TOOL "$2"
		cd ../../../
	else
		echo "The extension '$dep' is not available\n"
	fi
done

# watchers were started in the background above; block on them so callers (eg. a Phoenix `watchers:`
# entry) see one long-running process rather than an immediate exit
if [ -n "$PARALLEL" ]; then
	wait
fi
