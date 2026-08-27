#!/bin/sh
# This script is meant to be called by another script defined in each flavour 
# It cycles through a list of extensions (provided in args) and installs their JS deps, if any

DEPS=${1}
# TOOL="npm install"
TOOL=yarn

# Each extension declares the yarn it wants via `packageManager` in its assets/package.json, and corepack is what honours that pin, fetching the declared version on demand. So install corepack rather than yarn: `npm -g install yarn` still resolves to 1.22.x, which is never what we want.
command -v corepack >/dev/null 2>&1 || npm -g install corepack || echo "corepack is required to install JS deps!"
corepack enable 2>/dev/null || true
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

# Corepack's own built-in default, used for extensions that declare no `packageManager`, is also yarn 1, which would ignore the yarn 4 lockfiles those extensions ship, re-resolve every dependency, rewrite the lockfile in its own format, and enforce each dependency's `engines.node` range on the way. Deliberately unpinned: this is only a floor for extensions that have not pinned themselves, so "current" beats a version we would have to keep in step by hand.
corepack install -g yarn@stable || echo "could not set the default yarn, extensions with no packageManager pin may fall back to yarn 1"

# With no args we install. With a script name, only run it where package.json defines it — so a
# shared loop (eg. `just js-ext-build`) can ask every extension to build its own bundles without
# erroring on the ones that have none.
case "${2:-}" in
	watch*) PARALLEL=1 ;;
	*) PARALLEL="" ;;
esac

# Nothing here should ever run under yarn 1, so refuse rather than let it quietly re-resolve a yarn 4 lockfile. Reaching this means corepack is missing or disabled, or a global yarn 1 shadows its shim.
refuse_yarn_1() {
	version=$($1 --version 2>/dev/null)
	case "$version" in
		1.*)
			echo "  ERROR: '$1' is yarn $version here. Install corepack and run 'corepack enable', and make sure no global yarn 1 comes earlier on PATH."
			return 1
			;;
	esac
}

run_tool() {
	# `corepack use` rewrites this extension's `packageManager` pin (with its integrity hash) and regenerates the lockfile, so bumping every extension to a current yarn is one command rather than seven hand edits. It has to come before the yarn 1 check, since an extension with no pin yet is exactly the case we are here to fix.
	if [ "$2" = "yarn.bump" ]; then
		if [ "$SRC" = "deps" ]; then
			echo "  (fetched copy, not a working clone: pin this in the extension's own repo instead)"
			return 0
		fi
		# An extension that vendors its own yarn release via `yarnPath` ignores `packageManager` entirely, so bumping only the latter would leave the two disagreeing about which yarn actually runs. `yarn set version` updates both and swaps the vendored .cjs. `corepack use` covers everything else, including extensions with no pin yet, where yarn may not be runnable at all.
		# After bumping across a yarn major, check `git diff` for `npmMinimalAgeGate: 0` in .yarnrc.yml: the migration writes it to preserve older behaviour, which opts out of the publish-age check on new packages. Drop those lines to keep yarn's default.
		if grep -q '^yarnPath:' .yarnrc.yml 2>/dev/null ; then
			$1 set version stable || return $?
		else
			corepack use yarn@stable || return $?
		fi
		return 0
	fi
	refuse_yarn_1 $1 || return 1
	# Under CI yarn defaults to an immutable install, failing outright rather than touching the lockfile. That is the right default for a working clone under extensions/ or forks/, where a lockfile change is real and reviewable, so those keep it. For a fetched copy under deps/ it is not actionable: we never commit there, and a published extension can simply lag (iconify_ex ships a pre-migration yarn 1 lockfile on hex), which would otherwise take down every build until its next release.
	case "$SRC" in
		deps) IMMUTABLE=--no-immutable ;;
		*) IMMUTABLE= ;;
	esac
	if [ -z "$2" ]; then
		$1 $IMMUTABLE || return $?
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
		SRC=extensions run_tool $TOOL "$2" || FAILED="$FAILED $dep"
		cd ../../../
	elif cd "forks/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'forks/$dep' with args '$2'"
		SRC=forks run_tool $TOOL "$2" || FAILED="$FAILED $dep"
		cd ../../../
	elif cd "deps/$dep/assets" 2>/dev/null ; then
		echo "Install JS deps from extension 'deps/$dep' with args '$2'"
		SRC=deps run_tool $TOOL "$2" || FAILED="$FAILED $dep"
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
