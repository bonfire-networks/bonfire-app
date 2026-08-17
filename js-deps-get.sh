#!/bin/sh
# This script is meant to be called by another script defined in each flavour 
# It cycles through a list of extensions (provided in args) and installs their JS deps, if any

DEPS=${1} 
# TOOL="npm install"
TOOL=yarn

command -v $TOOL || (command -v npm && npm -g install $TOOL) || echo "$TOOL is required to install JS deps!"

# Extensions declare which yarn they need via `packageManager`, and a global yarn 1 rightly refuses to run in a yarn 4 project rather than rewriting its lockfile into another format. Corepack is what honours that pin, fetching the declared version on demand. 
command -v corepack >/dev/null 2>&1 && corepack enable 2>/dev/null || true
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

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

# extensions that failed, reported together at the end rather than aborting on the first, so one run tells you everything that is broken. Without this a failed bundle only shows up as a 404 in production
FAILED=""

for dep in $DEPS ; do

	# first match wins, mirroring how the Elixir side resolves: a local clone takes precedence over the fetched dep. Running both would build the same bundle twice and reported the second, unbuilt copy as a failure
	if cd "extensions/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'extensions/$dep' with args '$2'"
		run_tool $TOOL "$2" || FAILED="$FAILED $dep"
		cd ../../../
	elif cd "forks/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'forks/$dep' with args '$2'"
		run_tool $TOOL "$2" || FAILED="$FAILED $dep"
		cd ../../../
	elif cd "deps/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'deps/$dep' with args '$2'"
		run_tool $TOOL "$2" || FAILED="$FAILED $dep"
		cd ../../../
	else
		echo "The extension '$dep' is not available"
	fi
done

# watchers were started in the background above; block on them so callers (eg. a Phoenix `watchers:`
# entry) see one long-running process rather than an immediate exit
if [ -n "$PARALLEL" ]; then
	wait
fi

if [ -n "$FAILED" ]; then
	echo "FAILED to run '$2' for:$FAILED"
	exit 1
fi
