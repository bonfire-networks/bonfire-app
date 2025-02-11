# recipes for the `just` command runner: https://just.systems
# how to install: https://github.com/casey/just#packages

# we load all vars from .env file into the env of just commands
set dotenv-load
# and export just vars as env vars
set export

## Main configs - override these using env vars

# what flavour do we want?
FLAVOUR := env_var_or_default('FLAVOUR', "classic")
FLAVOUR_PATH := env_var_or_default('FLAVOUR_PATH', "flavours/" + FLAVOUR)

# do we want to use Docker? set as env var:
# - WITH_DOCKER=total : use docker for everything (default)
# - WITH_DOCKER=partial : use docker for services like the DB
# - WITH_DOCKER=easy : use docker for services like the DB & compiled utilities  (deprecated, now same as partial)
# - WITH_DOCKER=no : please no
WITH_DOCKER := env_var_or_default('WITH_DOCKER', "total")

MIX_ENV := env_var_or_default('MIX_ENV', "dev")

APP_NAME := "bonfire"

APP_DOCKER_REPO := "bonfirenetworks/"+APP_NAME
APP_DOCKER_REPO_ALT := "ghcr.io/bonfire-networks/bonfire-app"

ARCH_JUST := arch()
ARCH := if ARCH_JUST == "x86_64" { "amd64" } else { ARCH_JUST }
APP_DOCKER_IMAGE := env_var_or_default('APP_DOCKER_IMAGE', APP_DOCKER_REPO + ":latest-" + FLAVOUR + "-" + ARCH)
DB_DOCKER_VERSION := env_var_or_default('DB_DOCKER_VERSION', "17-3.5") 
# NOTE: we currently only use features available in Postgres 12+, though a more recent version is recommended if possible
DB_DOCKER_IMAGE := env_var_or_default('DB_DOCKER_IMAGE', if ARCH == "aarch64" { "ghcr.io/baosystems/postgis:"+DB_DOCKER_VERSION } else { "postgis/postgis:"+DB_DOCKER_VERSION+"-alpine" })
# DB_DOCKER_IMAGE := env_var_or_default('DB_DOCKER_IMAGE', "supabase/postgres")
# ELIXIR_DOCKER_IMAGE := env_var_or_default('ELIXIR_VERSION', "1.17") +"-erlang-"+env_var_or_default('ERLANG_VERSION', "27")+"-alpine-"+env_var_or_default('ERLANG_VERSION', "3.20")

# GRAPH_DB_URL := if WITH_DOCKER != "total" { env_var_or_default('GRAPH_DB_URL', "bolt://localhost:7687") } else { env_var_or_default('GRAPH_DB_URL', "bolt://graph:7687") } 

## Other configs - edit these here if necessary
EXT_PATH := "extensions/"
EXTRA_FORKS_PATH := "forks/"
APP_VSN_EXTRA := "beta"
APP_REL_DOCKERFILE :="Dockerfile.release"
APP_REL_DOCKERCOMPOSE :="docker-compose.release.yml"
APP_REL_CONTAINER := APP_NAME + "_release"
WEB_CONTAINER := APP_NAME +"_web"
APP_VSN := `grep -m 1 'version:' mix.exs | cut -d '"' -f2`
APP_BUILD := env_var_or_default('APP_BUILD', `git rev-parse --short HEAD || echo unknown`)
CONFIG_PATH := FLAVOUR_PATH + "/config"
UID := `id -u`
GID := `id -g`
PUBLIC_PORT := env_var_or_default('PUBLIC_PORT', '4000')
DOCKER_EXT_NETWORK := env_var_or_default('DOCKER_EXT_NETWORK', 'bonfire_default')
DOCKER_EXT_NETWORK_BOOL := if DOCKER_EXT_NETWORK == "bonfire_default" { "false" } else { "true" }
TUNNEL_SUBDOMAIN := env_var_or_default('TUNNEL_SUBDOMAIN', 'bonfire-test')

PROXY_CADDYFILE_PATH := if PUBLIC_PORT == "443" { "./config/deploy/Caddyfile2-https" } else { "./config/deploy/Caddyfile2" }

ENV_ENV := if MIX_ENV == "test" { "dev" } else { MIX_ENV }

## Configure just
# choose shell for running recipes
set shell := ["bash", "-uc"]
# set shell := ["bash", "-uxc"]
# support args like $1, $2, etc, and $@ for all args
set positional-arguments


#### GENERAL SETUP RELATED COMMANDS ####

help:
	@echo "Just commands for Bonfire:"
	@just --list


# Initialise env files, and create some required folders, files and softlinks
config:
	@just flavour $FLAVOUR

# Initialise a specific flavour, with its env files, and create some required folders, files and softlinks
@flavour select_flavour:
	echo "Switching to flavour '$select_flavour' in $MIX_ENV env..."
	just _pre-config $select_flavour
	just _pre-setup-env $select_flavour
	printf "\nNow make sure to finish the flavour setup with 'just setup'. You can also edit your config for flavour '$select_flavour' in /.env and ./config/ more generally.\n"

init services="db search": _pre-init 
	@just services "{{services}}"
	@echo "Light that fire! $APP_NAME with $FLAVOUR flavour in $MIX_ENV - docker:$WITH_DOCKER - $APP_VSN - $APP_BUILD - $FLAVOUR_PATH - {{os_family()}}/{{os()}} on {{ARCH}}"

@config-basic select_flavour=FLAVOUR:
	echo "Setting up flavour '$select_flavour' in $MIX_ENV env..."
	just _pre-config $select_flavour
	just setup
	echo "Setup done."

setup:
	{{ if MIX_ENV == "prod" { "just setup-prod" } else { "just setup-dev" } }}

#### COMMON COMMANDS ####

@_pre-config select_flavour=FLAVOUR: db-clean-migrations
	-rm ./config/deps.flavour.* 2> /dev/null
	-rm ./config/flavour_* 2> /dev/null
	just _pre-setup $select_flavour

@_pre-setup flavour='classic':
	mkdir -p config
	mkdir -p ./flavours/$flavour/config/prod/
	mkdir -p ./flavours/$flavour/config/dev/
	touch ./flavours/$flavour/config/deps.flavour.path
	just _ln-spark-deps	
	cd config && ln -sfn ../flavours/classic/config/* ./ && ln -sfn ../flavours/$flavour/config/* ./
	touch ./config/deps.path
	mkdir -p data
	mkdir -p data/uploads/
	mkdir -p data/search/dev
	mkdir -p priv/static/data
	mkdir -p extensions/
	mkdir -p forks/
	touch .erlang.cookie && chmod 644 .erlang.cookie

_ln-spark-deps:
	cd config && (find ../extensions/bonfire/ -type f -name "deps.*" -exec ln -sfn {} ./ \; || find ../deps/bonfire/ -type f -name "deps.*" -exec ln -sfn {} ./ \; || echo "Could not symlink the bonfire deps") && ls -la ./

@_pre-setup-env flavour='classic':
	echo "Using flavour '$flavour' at flavours/$flavour with env '$MIX_ENV' with vars from ./flavours/$flavour/config/$ENV_ENV/.env "
	test -f ./flavours/$flavour/config/$ENV_ENV/.env || just _pre-setup-env-init flavours/$flavour/config flavours/$flavour/config || just _pre-setup-env-init flavours/classic/config flavours/$flavour/config
	-rm .env
	ln -sf ./config/$ENV_ENV/.env ./.env

@_pre-setup-env-init from to:
	-cat {{from}}/templates/public.env {{from}}/templates/not_secret.env > {{to}}/$ENV_ENV/.env && echo "MIX_ENV=$MIX_ENV" >> {{to}}/$ENV_ENV/.env && echo "FLAVOUR=$flavour" >> {{to}}/$ENV_ENV/.env

@_pre-init: _assets-ln
	mkdir -p data
	mkdir -p ./priv/repo/
	-cp -rf $FLAVOUR_PATH/repo/* ./priv/repo/
	rm -rf ./data/current_flavour
	ln -sf ../$FLAVOUR_PATH ./data/current_flavour
	mkdir -p priv/static/public
	echo "Using $MIX_ENV env, with flavour: $FLAVOUR at path: $FLAVOUR_PATH"
# ulimit -n 524288

setup-dev:
	just build
	just deps-clean-data
	just deps-clean-api
	just deps-clean-unused
	WITH_GIT_DEPS=0 just mix deps.get
	just _ln-spark-deps
	just deps-fetch

extension-post-install: 
	just _ext-migrations-copy

_ext-migrations-copy: db-clean-migrations
	just mix bonfire.extension.copy_migrations --force

# FIXME: how should we know if user wants to use a prebuilt image or build their own? 
setup-prod:
	{{ if WITH_DOCKER != "no" { "just rel-docker-compose pull || echo Oops, could not download the Docker images!" } else { "just setup-prod-build" } }}

setup-prod-build:
	just build
	just deps-fetch --only prod
	just _deps-post-get  

# Prepare environment and dependencies
prepare:
	just _pre-setup $FLAVOUR
	just build

# Run the app in development
@dev *args='':
	MIX_ENV=dev just dev-run "db search" {{args}}

@dev-extra:
	iex --sname extra --cookie $ERLANG_COOKIE --remsh localenv@127.0.0.1

dev-run services="db search" *args='': 
	@just init "{{services}}"
	{{ if WITH_DOCKER == "total" { "just dev-docker $args" } else { "iex --name localenv@127.0.0.1 --cookie $ERLANG_COOKIE -S mix phx.server $args" } }}
# TODO: pass args to docker as well

@dev-remote: init
	{{ if WITH_DOCKER == "total" { "just dev-docker -e WITH_FORKS=0" } else { "WITH_FORKS=0 iex -S mix phx.server" } }}

@dev-app:
	just init
	cd rel/app/macos && ./run.sh

dev-search: 
	just dev-run search

dev-graph:
	just dev-run graph

dev-proxy: 
	just dev-profile proxy

dev-proxy-iex:
	just dev-profile-iex proxy

dev-profile profile: docker-stop-web
	just docker-compose --profile $profile up -d
	docker logs bonfire_web -f

dev-profile-iex profile:
	just docker-compose --profile $profile exec web iex --sname extra --remsh localenv@127.0.0.1

dev-federate:
	FEDERATE=yes HOT_CODE_RELOAD=0 HOSTNAME=`just local-tunnel-hostname` PUBLIC_PORT=443 just dev

dev-docker *args='': docker-stop-web
	just docker-compose {{args}} run -e HOT_CODE_RELOAD=0 --name $WEB_CONTAINER --service-ports web

# Generate docs from code & readmes
docs *args='':
	just mix docs {{args}}

# Analyse the codebase and generate some reports. Requires Graphviz and SQLite
arch:
	just mix arch.collect --no-coverage --include-deps 'bonfire' --include-deps 'bonfire_*' --include-deps 'activity_pub'
	just mix arch.report --format livemd
# just mix arch.explore.static
# just mix arch.explore.xrefs
# just mix arch.explore.apps
# -MIX_ENV=test just mix arch.explore.coverage
# just mix arch.dsm
# just mix arch.report.html
# mkdir -p reports/dev/static/html/data/
# just mix arch.apps.xref --format mermaid --out reports/dev/static/html/data/apps.mermaid
# just mix arch.apps.xref --format svg --out reports/dev/static/html/data/apps.svg
# just mix arch.xref --format svg --out reports/dev/static/modules.png Bonfire.Web.Router Bonfire.UI.Social.Routes Bonfire.UI.Me.Routes

# Compile the app + extensions
compile *args='':
	just mix bonfire.extension.compile {{args}}
	just mix compile {{args}}

# Force the app + extensions to recompile
recompile *args='':
	just compile --force {{args}}

dev-test:
	@MIX_ENV=test PHX_SERVER=yes just dev-run

# Run the app in dev mode, as a background service
dev-bg: init
	{{ if WITH_DOCKER == "total" { "just docker-stop-web && just docker-compose run --detach --name $WEB_CONTAINER --service-ports web elixir -S mix phx.server" } else { 'elixir --erl "-detached" -S mix phx.server" && echo "Running in background..." && (ps au | grep beam)' } }}

# Run latest database migrations (eg. after adding/upgrading an app/extension)
db-migrate:
	just mix "ecto.migrate"
#	just mix "excellent_migrations.migrate"

db-migration-checks:
	just mix "excellent_migrations.migrate"

# Run latest database seeds (eg. inserting required data after adding/upgrading an app/extension)
db-seeds: db-migrate
	just mix "ecto.seeds"

# Reset the DB (caution: this means DATA LOSS)
db-reset: init dev-search-reset db-pre-migrations
	just mix "ecto.reset"

# Backup and then Upgrade the Postgres DB version (NOTE: does not work with Postgis geo extension) using https://github.com/pgautoupgrade/docker-pgautoupgrade 
db-upgrade-dev version="15": db-dump-dev 
	just _db-upgrade-dev {{version}}

_db-upgrade-dev version="15": docker-stop
	DB_DOCKER_IMAGE=pgautoupgrade/pgautoupgrade:{{version}}-alpine PGAUTO_ONESHOT=yes just docker-compose up db 

db-dump-dev: 
	just services db
	just _db-dump docker-compose.yml 

dev-search-reset: dev-search-reset-docker
	rm -rf data/search/dev

dev-search-reset-docker:
	{{ if WITH_DOCKER != "no" { "just docker-compose rm -s -v search" } else {""} }}

# Rollback previous DB migration (caution: this means DATA LOSS)
db-rollback:
	just mix "ecto.rollback"

# Rollback ALL DB migrations (caution: this means DATA LOSS)
db-rollback-all:
	just mix "ecto.rollback --all"

#### UPDATE COMMANDS ####

# Update the dev app and all dependencies/extensions/forks, and run migrations
update: init update-repo prepare update-forks update-deps js-deps-fetch
	just mix deps.get
	just _deps-post-get
#   just mix compile
#	just db-migrate

# Update the app and Bonfire extensions in ./deps
update-app: update-repo update-deps

@db-clean-migrations:
	rm -rf ./flavours/*/priv/repo/migrations/*
	rm -rf ./priv/repo/*
	rm -rf deps/bonfire/priv/repo/*
	rm -rf extensions/bonfire/priv/repo/*

_pre-update-deps: db-clean-migrations
	@rm -rf deps/*/assets/pnpm-lock.yaml
	@rm -rf deps/*/assets/yarn.lock

# Update Bonfire extensions in ./deps
update-deps: _pre-update-deps
	just mix-remote updates

update-repo: _pre-contrib-hooks
	just git-publish . pull || git pull

update-repo-pull:
	just git-publish . pull only

# Update to the latest Bonfire extensions in ./deps
update-deps-bonfire:
	just mix-remote bonfire.deps.update

# Update every single dependency (use with caution)
update-deps-all: _pre-update-deps
	just update-deps-js
	just _assets-ln
	just update-forks
	COMPILE_DISABLED_EXTENSIONS=all just mix-remote "deps.update --all"
	just _deps-post-get
	just js-ext-deps outdated
	-just mix "hex.outdated --all"

# Update every single dependency (use with caution)
update-deps-js: 
	just js-ext-deps
	just js-ext-deps upgrade

# Update a specify dep (eg. `just update.dep needle`)
update-dep dep: _pre-update-deps
	just update-dep-simple $dep 
	just _deps-post-get
	./js-deps-get.sh $dep

update-dep-simple dep: 
	just update-fork $dep pull
	COMPILE_DISABLED_EXTENSIONS=all just mix-remote "deps.update $dep"

# Pull the latest commits from all forks
@update-forks:
	(just git-fetch-all && just update-forks-all rebase) || (echo "Fetch all clones with Jungle not available, will fetch one by one instead." && just update-forks-all pull)

update-forks-all cmd='pull' extra='':
	just update-fork-path $EXT_PATH $cmd
	just update-fork-path $EXTRA_FORKS_PATH $cmd

# Pull the latest commits from all forks
update-fork dep cmd='pull' extra='' mindepth='0' maxdepth='0':
	-just update-fork-path $EXT_PATH/{{dep}} {{cmd}} {{extra}} {{mindepth}} {{maxdepth}}
	-just update-fork-path $EXTRA_FORKS_PATH/{{dep}} {{cmd}} {{extra}} {{mindepth}} {{maxdepth}}

update-fork-path path cmd='pull' extra='' mindepth='0' maxdepth='1':
	@chmod +x git-publish.sh
	find {{path}} -mindepth {{mindepth}} -maxdepth {{maxdepth}} -type d -exec ./git-publish.sh {} {{cmd}} {{extra}} \;

# Fetch locked versions of deps (Elixir and JS), including ones also cloned locally
@deps-fetch *args='':
	just deps-get {{args}}
	-just mix-remote deps.get {{args}} || echo "Oops, could not download mix deps"
	just _deps-post-get
	just js-deps-fetch

# Fetch locked versions of Elixir deps (except ones also cloned locally)
@deps-get *args='':
	just mix deps.get {{args}}

@_deps-post-get: extension-post-install
	ln -sf ../../../priv/static extensions/bonfire/priv/static || ln -sf ../../../priv/static deps/bonfire/priv/static || echo "Could not find a priv/static dir to use"
	-cd deps/bonfire/priv && ln -sf ../../../priv/repo
	-cd extensions/bonfire/priv && ln -sf ../../../priv/repo
	mkdir -p priv/static/data
	mkdir -p data
	mkdir -p data/uploads
	-cd priv/static/data && ln -s ../../../data/uploads

deps-clean *args='':
	just mix deps.clean --build {{args}}

@deps-clean-bonfire:
	just mix bonfire.deps.clean

@deps-clean-data:
	just mix bonfire.deps.clean.data

@deps-clean-api:
	just mix bonfire.deps.clean.api

@deps-clean-web:
	just deps-clean plug
	just deps-clean phoenix_html
	just deps-clean bonfire_ui_common
	just deps-clean bonfire

#### DEPENDENCY & EXTENSION RELATED COMMANDS ####

js-deps-fetch: js-ext-deps _assets-ln

@js-ext-deps yrn_args='':
	chmod +x ./config/deps.js.sh
	just cmd ./config/deps.js.sh $yrn_args

@_assets-ln:
	{{ if path_exists("extensions/bonfire_ui_common")=="true" { "ln -sf extensions/bonfire_ui_common/assets && echo Assets served from the local UI.Common extension will be used" } else {"ln -sf deps/bonfire_ui_common/assets "} }}

deps-outdated: deps-unlock-unused
	@just mix-remote "hex.outdated --all"

deps-clean-unused:
	@just mix "deps.clean --build --unused"

deps-unlock-unused:
	@just mix "deps.clean --unlock --unused"

dep-clean dep:
	@just mix "deps.clean $dep --build"
	@just mix "deps.clean bonfire --build"

# Clone a git dep and use the local version, eg: `just dep-clone-local bonfire_me https://github.com/bonfire-networks/bonfire_me`
dep-clone-local dep repo:
	git clone {{repo}} {{EXT_PATH}}{{dep}} 2> /dev/null || (cd {{EXT_PATH}}{{dep}} ; git pull)
	echo "Remember to add this to ./config/deps.flavour.path: {{dep}} = \"{{EXT_PATH}}{{dep}}\""
# just dep-go-local dep=$dep

# Clone all bonfire deps / extensions
deps-clone-local-all:
	curl -s https://api.github.com/orgs/bonfire-networks/repos?per_page=500 | ruby -rrubygems -e 'require "json"; JSON.load(STDIN.read).each { |repo| %x[just dep.clone.local dep="#{repo["name"]}" repo="#{repo["ssh_url"]}" ]}'

# Switch to using a local path, eg: just dep.go.local needle
# dep-go-local dep:
# 	just dep-go-local-path $dep $EXT_PATH$dep

# Switch to using a local path, specifying the path, eg: just dep.go.local dep=needle path=./libs/needle
# dep-go-local-path dep path:
# 	just dep-local add $dep $path
# 	just dep-local enable $dep $path

# Switch to using a git repo, eg: just dep.go.git needle https://github.com/bonfire-networks/needle (specifying the repo is optional if previously specified)
# dep-go-git dep repo:
# 	-just dep-git add $dep $repo
# 	just dep-git enable $dep NA
# 	just dep-local disable $dep NA

# Switch to using a library from hex.pm, eg: just dep.go.hex dep="needle" version="_> 0.2" (specifying the version is optional if previously specified)
# dep-go-hex dep version:
# 	-just dep-hex add dep=$dep version=$version
# 	just dep-hex enable $dep NA
# 	just dep-git disable $dep NA
# 	just dep-local disable $dep NA

# add/enable/disable/delete a hex dep with messctl command, eg: `just dep-hex enable needle 0.2`
# dep-hex command dep version:
# 	just messctl "$command $dep $version"
# 	just mix "deps.clean $dep"

# add/enable/disable/delete a git dep with messctl command, eg: `just dep-hex enable needle https://github.com/bonfire-networks/needle
# dep-git command dep repo:
# 	just messctl "$command $dep $repo config/deps.git"
# 	just mix "deps.clean $dep"

# add/enable/disable/delete a local dep with messctl command, eg: `just dep-hex enable needle ./libs/needle`
# dep-local command dep path:
# 	just messctl "$command $dep $path config/deps.path"
# 	just mix "deps.clean $dep"

# Utility to manage the deps in deps.hex, deps.git, and deps.path (eg. `just messctl help`)
# messctl *args='': init
# 	{{ if WITH_DOCKER == "no" { "messctl $args" } else { "just docker-compose run web messctl $args" } }}

#### CONTRIBUTION RELATED COMMANDS ####

_pre-push-hooks: _pre-contrib-hooks
	just icons-uniq
	just mix format 
	just deps-clean bonfire
# just mix format.all  # FIXME
#	just mix changelog

_pre-contrib-hooks:
	-ex +%s,/extensions/,/deps/,e -scwq config/deps_hooks.js
	rm -rf forks/*/data/uploads/favicons/
	rm -rf extensions/*/data/uploads/favicons/
# -sed -i '' 's,/extensions/,/deps/,' config/deps_hooks.js

icons-uniq:
	sort -u -o assets/static/images/icons/icons.css assets/static/images/icons/icons.css

# Push all changes to the app and extensions in ./forks
contrib: _pre-push-hooks contrib-forks-publish _pre-push-hooks git-publish

# Push all changes to the app and extensions in forks, increment the app version number, and push a new version/release
contrib-release: _pre-push-hooks contrib-forks-publish update contrib-app-release

# Rebase app's repo and push all changes to the app
contrib-app-only: _pre-push-hooks update-repo git-publish

# Increment the app version number and commit/push
contrib-app-release: _pre-push-hooks contrib-app-release-increment git-publish

# Increment the app version number
@contrib-app-release-increment:
	just escript_common release "./ $APP_VSN_EXTRA"

contrib-forks-publish: update-forks

contrib-rel-push: contrib-release rel-build rel-push

# Count lines of code (requires cloc: `brew install cloc`)
cloc:
	cloc lib config extensions/*/lib extensions/*/test test

# Fetch latest remote commits from all extensions/forks git repos (does not checkout or rebase though)
git-fetch-all:
	just escript_dep jungle
# jungle git fetch || just escript_dep jungle # ^ experimental: replaced racket script with escript

# Run the git add command on each fork
git-forks-add: deps-git-fix
	find $EXT_PATH -mindepth 1 -maxdepth 1 -type d -exec echo add {} \; -exec git -C '{}' add --all . \;

# Run a git status on each fork
git-forks-status:
	@jungle git status || find $EXT_PATH -mindepth 1 -maxdepth 1 -type d -exec echo {} \; -exec git -C '{}' status \;

# Run a git command on each fork (eg. `just git-forks pull` pulls the latest version of all local deps from its git remote
git-forks command:
	@find $EXT_PATH -mindepth 1 -maxdepth 1 -type d -exec echo $command {} \; -exec git -C '{}' $command \;

# List all diffs in forks
git-diff:
	@find $EXT_PATH -mindepth 1 -maxdepth 1 -type d -exec echo {} \; -exec git -C '{}' --no-pager diff --color --exit-code \;

# Run a git command on each dep, to ignore chmod changes
deps-git-fix:
	find ./deps -mindepth 1 -maxdepth 1 -type d -exec git -C '{}' config core.fileMode false \;
	find ./forks -mindepth 1 -maxdepth 1 -type d -exec git -C '{}' config core.fileMode false \;

# Draft-merge another branch, eg `just git-merge with-valueflows-api` to merge branch `with-valueflows-api` into the current one
@git-merge branch:
	git merge --no-ff --no-commit $branch

# Find any git conflicts in forks
@git-conflicts:
	find $EXT_PATH -mindepth 1 -maxdepth 1 -type d -exec echo add {} \; -exec git -C '{}' diff --name-only --diff-filter=U \;

@git-publish dir='.' cmd='pull' extra='':
	chmod +x git-publish.sh
	./git-publish.sh {{dir}} {{cmd}} {{extra}}

#### TESTING RELATED COMMANDS ####

# Run tests. You can also run only specific tests, eg: `just test extensions/bonfire_social/test`
test *args='':
	@echo "Testing {{args}}..."
	MIX_ENV=test just mix test {{args}}

# test-federation *args='':
# 	MIX_TEST_ONLY=federation just test --exclude ui backend --include federation {{args}}

test-backend *args='':
	MIX_TEST_ONLY=backend just test --exclude ui --exclude federation --exclude todo --include backend {{args}}

test-ui *args='':
	MIX_TEST_ONLY=ui just test --exclude backend --exclude federation --exclude todo --include ui {{args}}

# Run only stale tests
test-stale *args='':
	@echo "Testing {{args}}..."
	MIX_ENV=test just mix test --stale {{args}}

# Run tests (ignoring changes in local forks)
test-remote *args='':
	@echo "Testing {{args}}..."
	MIX_ENV=test just mix-remote test {{args}}

# Run stale tests, and wait for changes to any module code, and re-run affected tests
test-watch *args='':
	@echo "Testing {{args}}..."
	MIX_ENV=test just mix test.watch --stale --exclude mneme {{args}}

test-watch-mneme *args='':
	@echo "Testing {{args}}..."
	MIX_ENV=test just mix mneme.watch --stale --include mneme {{args}}

test-watch-full *args='':
	@echo "Testing {{args}}..."
	MIX_ENV=test just mix test.watch --exclude mneme {{args}}
# MIX_ENV=test just mix mneme.watch {{args}}

# Run stale tests, and wait for changes to any module code, and re-run affected tests, and interactively choose which tests to run
test-interactive *args='':
	@MIX_ENV=test just mix test.interactive --stale {{args}}

ap_lib := "forks/activity_pub/test/activity_pub"
ap_integration := "extensions/bonfire_federate_activitypub/test/activity_pub_integration"
ap_boundaries := "extensions/bonfire_federate_activitypub/test/ap_boundaries"
ap_ext := "extensions/*/test/*federat* extensions/*/test/*/*federat* extensions/*/test/*/*/*federat*"
# ap_two := "forks/bonfire_federate_activitypub/test/dance"

test-federation: _test-dance-positions
	just test-stale {{ ap_lib }}
	just test-stale {{ ap_integration }}
	just test-stale {{ ap_ext }}
	just _test-dance-positions
	just _test-db-dance-reset
	TEST_INSTANCE=yes just test-stale --only test_instance
	just _test-dance-positions

test-federation-lib *args=ap_lib: _test-dance-positions
	just test-watch {{args}}

test-federation-bonfire *args=ap_integration: _test-dance-positions
	just test-watch {{args}}

test-federation-boundaries *args="extensions/bonfire_federate_activitypub/test/boundaries": _test-dance-positions
	just test-watch {{args}}

test-federation-in-extensions *args=ap_ext: _test-dance-positions
	just test-watch {{args}}

test-federation-dance *args='': _test-dance-positions _test-db-dance-reset
	TEST_INSTANCE=yes HOSTNAME=localhost just test --only test_instance {{args}}
	just _test-dance-positions

test-federation-dance-unsigned *args='': _test-dance-positions _test-db-dance-reset
	ACCEPT_UNSIGNED_ACTIVITIES=1 TEST_INSTANCE=yes HOSTNAME=localhost just test --only test_instance {{args}}
	just _test-dance-positions

test-openid-dance *args='extensions/bonfire_open_id/test': _test-dance-positions _test-db-dance-reset
	TEST_INSTANCE=yes HOSTNAME=localhost just test --only test_instance {{args}} 
	just _test-dance-positions

# test-boostomatic-dance *args='extensions/boostomatic/test': _test-dance-positions _test-db-dance-reset
# 	TEST_INSTANCE=yes HOSTNAME=localhost just test --only live_federation {{args}} 
# 	just _test-dance-positions

_test-dance-positions: 
	TEST_INSTANCE=yes MIX_ENV=test just mix deps.clean bonfire --build

test-federation-live-DRAGONS *args='':
	FEDERATE=yes PHX_SERVER=yes HOSTNAME=`just local-tunnel-hostname` PUBLIC_PORT=443 just test --only live_federation {{args}}

load_testing:
	TEST_INSTANCE=yes just mix bonfire.load_testing

# dev-test-watch: init ## Run tests
# 	just docker-compose run --service-ports -e MIX_ENV=test web iex -S mix phx.server

# Create or reset the test DB
test-db-reset: init db-pre-migrations _test-db-dance-reset
	{{ if WITH_DOCKER == "total" { "just docker-compose run -e MIX_ENV=test web mix ecto.drop --force" } else { "MIX_ENV=test just mix ecto.drop --force" } }}

_test-db-dance-reset: init db-pre-migrations
	TEST_INSTANCE=yes {{ if WITH_DOCKER == "total" { "just docker-compose run -e MIX_ENV=test web mix ecto.drop --force" } else { "MIX_ENV=test just mix ecto.drop --force" } }}
	TEST_INSTANCE=yes {{ if WITH_DOCKER == "total" { "just docker-compose run -e MIX_ENV=test web mix ecto.drop --force -r Bonfire.Common.TestInstanceRepo" } else { "MIX_ENV=test just mix ecto.drop --force -r Bonfire.Common.TestInstanceRepo" } }}

#### RELEASE RELATED COMMANDS (Docker-specific for now) ####
_rel-init:
	MIX_ENV=prod just _pre-init

rel-config: config _rel-init _rel-prepare

# copy current flavour's config, without using symlinks
@_rel-config-prepare:
	rm -rf data/current_flavour
	mkdir -p data
	rm -rf flavours/*/config/*/dev
	cp -rfL flavours/classic data/current_flavour
	cp -rfL $FLAVOUR_PATH/* data/current_flavour/
	cp -rfL extensions/bonfire/deps.* data/current_flavour/config/ || cp -rfL deps/bonfire/deps.* data/current_flavour/config/ || echo "Could not copy the deps definitions from the bonfire dep"

# copy current flavour's config, without using symlinks
@_rel-prepare: _rel-config-prepare
	mkdir -p extensions/
	mkdir -p forks/
	mkdir -p deps/
	mkdir -p data/uploads/
	mkdir -p data/null/
	touch data/current_flavour/config/deps.path

# Build the Docker image (with no caching)
rel-rebuild:
	just rel-build {{EXT_PATH}} --no-cache

# Build the Docker image (NOT including changes to local forks)
rel-build ARGS="":
	@echo "Please note that the build will not include any changes in forks that haven't been committed and pushed, you may want to run just contrib-release first."
	@just rel-build-with-opts remote {{ ARGS }}

rel-build-with-clones ARGS="":
	@echo "Please note that the build will include changes in forks that haven't been committed and pushed."
	@just rel-build-with-opts local {{ ARGS }}

# Build the release
rel-build-with-opts USE_EXT ARGS="":
	@just {{ if WITH_DOCKER != "no" {"rel-build-docker"} else {"rel-build-OTP"} }} {{ USE_EXT }} {{ ARGS }}

# Build the OTP release
rel-build-OTP USE_EXT="local" ARGS="": _rel-init _rel-prepare
	WITH_DOCKER=no just _rel-build-OTP {{ USE_EXT }} {{ ARGS }}

_rel-build-OTP USE_EXT="local" ARGS="": 
	just _rel-compile-OTP {{ USE_EXT }} {{ ARGS }}
	just _rel-compile-assets {{ USE_EXT }}
	just _rel-release-OTP {{ USE_EXT }}

_rel-compile-OTP USE_EXT="local" ARGS="": 
	just rel-mix {{ USE_EXT }} "compile --return-errors {{ ARGS }}"

_rel-compile-assets USE_EXT="local" ARGS="": 
	-rm -rf priv/static
	yarn -v || npm install --global yarn
	git checkout HEAD -- "flavours/*/config/flavour_assets/hooks/*"
	just js-ext-deps
	cd ./assets && yarn && yarn build && cd ..
	just rel-mix {{ USE_EXT }} phx.digest {{ ARGS }}

_rel-release-OTP USE_EXT="local" ARGS="": 
	just rel-mix {{ USE_EXT }} release {{ ARGS }}

rel-mix USE_EXT="local" ARGS="":
	@echo {{ ARGS }}
	@MIX_ENV=prod CI=1 just {{ if USE_EXT=="remote" {"mix-remote"} else {"mix"} }} {{ ARGS }}

# Build the Docker image
@rel-build-docker USE_EXT="local" ARGS="": _rel-init _rel-prepare assets-prepare
	export $(./tool-versions-to-env.sh 3 | xargs) && export $(grep -v '^#' .tool-versions.env | xargs) && export ELIXIR_DOCKER_IMAGE="${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION}" && echo $ELIXIR_DOCKER_IMAGE && just rel-build-path {{ if USE_EXT=="remote" {"data/null"} else {EXT_PATH} }} {{ ARGS }}

rel-build-path FORKS_TO_COPY_PATH ARGS="":
	@echo "Building $APP_NAME with flavour $FLAVOUR for arch {{ARCH}} with image $ELIXIR_DOCKER_IMAGE."
	@MIX_ENV=prod docker build {{ ARGS }} --progress=plain \
		--build-arg FLAVOUR=$FLAVOUR \
		--build-arg FLAVOUR_PATH=data/current_flavour \
		--build-arg WITH_IMAGE_VIX=$WITH_IMAGE_VIX \
		--build-arg WITH_LV_NATIVE=$WITH_LV_NATIVE \
		--build-arg WITH_AI=$WITH_AI \
		--build-arg ALPINE_VERSION=$ALPINE_VERSION \
		--build-arg ELIXIR_DOCKER_IMAGE=$ELIXIR_DOCKER_IMAGE \
		--build-arg FORKS_TO_COPY_PATH={{ FORKS_TO_COPY_PATH }} \
		-t $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-$APP_BUILD-{{ARCH}}  \
		-f $APP_REL_DOCKERFILE .
	@echo Build complete, tagged as: $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-$APP_BUILD-{{ARCH}}
	@echo "Remember to run just rel-tag or just rel-push"


# Add latest tag to last build
@rel-tag label='latest':
	just rel-tag-commit $APP_BUILD {{label}}

@rel-tag-commit build label='latest': 
	just rel-tag-version-commit $APP_VSN {{build}} {{label}}

@rel-tag-version version label='latest':
	just rel-tag-version-commit {{version}} $APP_BUILD {{label}}

@rel-tag-version-commit version build label='latest': _rel-init
	just rel-tag-version-commit-flavour {{version}} {{build}} $FLAVOUR {{label}}

@rel-tag-version-commit-flavour version build flavour label='latest': _rel-init
	docker tag $APP_DOCKER_REPO:release-{{flavour}}-{{version}}-{{build}}-{{ARCH}} $APP_DOCKER_REPO:{{label}}-{{flavour}}-{{ARCH}}
	docker tag $APP_DOCKER_REPO:release-{{flavour}}-{{version}}-{{build}}-{{ARCH}} $APP_DOCKER_REPO_ALT:release-{{flavour}}-{{version}}-{{build}}-{{ARCH}}
	docker tag $APP_DOCKER_REPO:release-{{flavour}}-{{version}}-{{build}}-{{ARCH}} $APP_DOCKER_REPO_ALT:{{label}}-{{flavour}}-{{ARCH}}

# Add latest tag to last build and push to Docker Hub
rel-push label='latest':
	@just rel-tag {{label}}
	@echo just rel-push-only $APP_BUILD {{label}}
	@just rel-push-only $APP_BUILD {{label}}

rel-push-only build label='latest':
	just rel-push-only-version $APP_VSN {{build}}

rel-push-only-version version build label='latest':
	@echo "Pushing to $APP_DOCKER_REPO"
	@docker login && docker push $APP_DOCKER_REPO:release-$FLAVOUR-{{version}}-{{build}}-{{ARCH}} && docker push $APP_DOCKER_REPO:{{label}}-$FLAVOUR-{{ARCH}}
# @just rel-push-only-alt {{build}} {{label}}

rel-push-only-alt build label='latest':
	@echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin
	@echo "Pushing to $APP_DOCKER_REPO_ALT"
	@docker push $APP_DOCKER_REPO_ALT:release-$FLAVOUR-$APP_VSN-{{build}}-{{ARCH}} && docker push $APP_DOCKER_REPO_ALT:{{label}}-$FLAVOUR-{{ARCH}}

# Run the app in Docker & starts a new `iex` console
rel-run services="db proxy": _rel-init docker-stop-web  
	just rel-services "{{services}}"
	echo Run with Docker based on image $APP_DOCKER_IMAGE
	@just rel-docker-compose run --name $WEB_CONTAINER --service-ports --rm web bin/bonfire start_iex

# Run the app in Docker, and keep running in the background
rel-run-bg services="db proxy": _rel-init docker-stop-web
	just rel-services "{{services}}"
	@just rel-docker-compose up -d

# Stop the running release
rel-stop:
	@just rel-docker-compose stop

rel-update: update-repo-pull
	@just rel-docker-compose pull
	@echo Remember to run migrations on your DB...

rel-logs:
	@just rel-docker-compose logs

# Stop the running release
rel-down: rel-stop
	@just rel-docker-compose down

# Runs a the app container and opens a simple shell inside of the container, useful to explore the image
rel-shell services="db proxy": _rel-init docker-stop-web
	just rel-services "{{services}}"
	@just rel-docker-compose run --name $WEB_CONTAINER --service-ports --rm web /bin/bash

# Runs a simple shell inside of the running app container, useful to explore the image
rel-shell-bg services="db proxy": _rel-init 
	just rel-services "{{services}}"
	@just rel-docker-compose exec web /bin/bash

# Runs a simple shell inside of the DB container, useful to explore the image
rel-db-shell-bg: _rel-init 
	just rel-services db
	@just rel-docker-compose exec db /bin/bash

rel-db-dump: _rel-init 
	just rel-services db
	just _db-dump $APP_REL_DOCKERCOMPOSE "-p $APP_REL_CONTAINER"

rel-db-restore: _rel-init 
	just rel-services db
	cat $file | docker exec -i bonfire_release_db_1 /bin/bash -c "PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER $POSTGRES_DB"

rel-services services="db search":
	{{ if WITH_DOCKER != "no" { "echo Starting docker services to run in the background: $services && just rel-docker-compose up -d $services" } else {""} }}

rel-docker-compose *args:
	just docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE {{args}}

#### DOCKER-SPECIFIC COMMANDS ####

# Start background docker services (eg. db and search backends).
@services services="db search":
	{{ if MIX_ENV == "prod" { "just rel-services \"$services\"" } else { "just dev-services \"$services\"" } }}

@dev-services services="db search":
	{{ if WITH_DOCKER != "no" { "(echo Starting docker services to run in the background: $services && just docker-compose up -d \"$services\") || echo \"WARNING: You may want to make sure the docker daemon is started or run 'colima start' first.\"" } else { "echo Skipping docker services"} }}

# Build the docker image
@build: init
	mkdir -p deps
	{{ if WITH_DOCKER != "no" { "just docker-compose pull || echo Oops, could not download the Docker images!" } else { "just mix hex_setup" } }}
	{{ if WITH_DOCKER == "total" { "just docker-compose build" } else { "echo ." } }}

# Build the docker image
rebuild: init
	{{ if WITH_DOCKER != "no" { "mkdir -p deps && just docker-compose build --no-cache" } else { "echo Skip building container..." } }}

_db-dump docker_compose compose_args="": 
	-mv data/db_dump.sql data/db_dump.archive.sql
	just _db-shell {{docker_compose}} pg_dump {{compose_args}} " > data/db_dump.sql"

_db-shell docker_compose cmd="psql" compose_args="" extra_args="": 
	just docker-compose -f {{docker_compose}} {{compose_args}} exec --user $POSTGRES_USER db /bin/bash -c "PGPASSWORD=$POSTGRES_PASSWORD {{cmd}} --username $POSTGRES_USER" {{extra_args}}

# Run a specific command in the container (if used), eg: `just cmd messclt` or `just cmd time` or `just cmd "echo hello"`
@cmd *args='': init docker-stop-web
	{{ if WITH_DOCKER == "total" { "echo Run $args in docker && just docker-compose run --name $WEB_CONTAINER --service-ports web $args" } else {" echo Run $args && $args"} }}

cwd *args:
	cd {{invocation_directory()}}; {{args}}

cwd-test *args:
	cd {{invocation_directory()}}; MIX_ENV=test mix test {{args}}

# Open the shell of the web container, in dev mode
shell:
	just cmd bash

@docker-stop-web:
	-docker stop $WEB_CONTAINER
	-docker rm $WEB_CONTAINER

@docker *args='':
	export $(./tool-versions-to-env.sh 3 | xargs) && export $(grep -v '^#' .tool-versions.env | xargs) && export ELIXIR_DOCKER_IMAGE="${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION}" && docker {{args}}

@docker-compose *args='':
	just docker compose {{args}}

@docker-stop:
	just docker-compose stop

#### MISC COMMANDS ####

# Open an interactive console
@imix *args='':
	just cmd iex -S mix {{args}}

# Run a specific mix command, eg: `just mix deps.get` or `just mix "deps.update needle"`
@mix *args='':
	echo % mix {{args}}
	{{ if MIX_ENV == "prod" { "just mix-maybe-prod $args" } else { "just cmd mix $args" } }}

@mix-eval *args='': init
	echo % mix eval "{{args}}"
	{{ if MIX_ENV == "prod" {"echo Skip"} else { 'mix eval "$args"' } }}

@mix-maybe-prod *args='':
	{{ if WITH_DOCKER != "no" { "echo Ignoring mix commands when using docker in prod" } else { "just mix-maybe-prod-pre-release $args" } }}

@mix-maybe-prod-pre-release *args='':
	{{ if path_exists("./_build/prod/rel/bonfire/bin/bonfire")=="true" { "echo Ignoring mix commands since we already have a prod release (delete _build/prod/rel/bonfire/bin/bonfire if you want to build a new release)" } else { "just cmd mix $args" } }}

# Run a specific mix command, while ignoring any deps cloned into forks, eg: `just mix-remote deps.get` or `just mix-remote deps.update needle`
mix-remote *args='': init
	echo % WITH_FORKS=0 mix {{args}}
	{{ if WITH_DOCKER == "total" { "just docker-compose run -e WITH_FORKS=0 web mix $args" } else {"WITH_FORKS=0 mix $args"} }}

xref-dot:
	just mix xref graph --format dot --include-siblings
	(awk '{if (!a[$0]++ && $1 != "}") print}' extensions/*/xref_graph.dot; echo }) > docs/xref_graph.dot
	dot -Tsvg docs/xref_graph.dot -o docs/xref_graph.svg

db-schema-ecto-image image_format="svg":
	just db-schema-ecto dot && dot -T{{ image_format }} docs/db_schema_ecto_erd.dot -o docs/db_schema_ecto_erd.{{ image_format }} 

db-schema-ecto format="dot":
	just mix ecto.gen.erd --output-path=docs/db_schema_ecto_erd.{{ format }}

# Run a specific exh command, see https://github.com/rowlandcodes/exhelp
exh *args='':
	just cmd "exh -S mix {{args}}"

deps-licenses:
	@mkdir -p docs/DEPENDENCIES/
	just mix-remote licenses && mv DEPENDENCIES.md docs/DEPENDENCIES/$FLAVOUR.md

audit:
	AS_UMBRELLA=1 just mix sobelow

# Extract strings to-be-localised from the app and installed extensions
localise-extract:
	just mix "bonfire.localise.extract"
	cd priv/localisation/ && for f in *.pot; do mv -- "$f" "${f%.pot}.po"; done
# TODO: copy .pot strings from extensions/deps
# cp extensions/*/priv/gettext/* priv/localisation/
# cp forks/*/priv/gettext/* priv/localisation/

@localise-tx-init:
	pip install transifex-client
	tx config mapping-bulk -p bonfire --source-language en --type PO -f '.po' --source-file-dir priv/localisation/ -i fr -i es -i it -i de --expression 'priv/localisation/<lang>/LC_MESSAGES/{filename}{extension}' --execute
# curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash

@localise-tx-pull:
	tx pull --all --minimum-perc=5 --force
	just mix deps.compile bonfire_common --force

@localise-tx-push:
	tx push --source

@localise-extract-push: localise-extract localise-tx-push

@assets-prepare:
	-mkdir -p priv/static
	-mkdir -p priv/static/data
	-mkdir -p priv/static/data/uploads
	-mkdir -p rel/overlays/
	-cp lib/*/*/overlay/* rel/overlays/

# Workarounds for some issues running migrations
@db-pre-migrations:
	-touch deps/*/lib/migrations.ex
	-touch extensions/*/lib/migrations.ex
	-touch forks/*/lib/migrations.ex
	-touch priv/repo/*

# Generate secrets
@secrets:
	{{ if MIX_ENV == "prod" { "just rands" } else if WITH_DOCKER=="total" { "just rands" } else { "just mix-secrets" } }}

@rands:
	just rand
	just rand
	just rand

@mix-secrets: 
	just escript_common secrets --file .env
# ./lib/mix/tasks/secrets/secrets 128 3

@escript_common name *args='':
	-rm lib/mix/tasks
	{{ if path_exists("lib/mix/tasks")=="true" { "echo ." } else {"just ln-mix-tasks"} }}
	just escript lib/mix/tasks {{name}} {{args}}

@escript_ext name *args='':
	{{ if path_exists("extensions/"+name)=="true" { "just escript extensions/ $name $args" } else {"just escript_dep $name $args"} }}

@escript_dep name *args='':
	just dep-check {{name}}
	{{ if path_exists("forks/"+name)=="true" { "just escript forks/ $name $args" } else {"just escript deps/$name $name $args"} }}

@escript path name *args='':
	cd {{path}}/{{name}}/ && (stat {{name}} || mix escript.build) 
	{{path}}/{{name}}/{{name}} {{args}}

@dep-check name:
	{{ if path_exists("forks/"+name)=="true" { "echo ." } else {"just deps-get"} }}

@ln-mix-tasks:
	mkdir -p lib/mix && cd lib/mix/ && {{ if path_exists("extensions/bonfire_common/lib/mix_tasks")=="true" { "echo Link to bonfire_common to dev clone && ln -sf ../../extensions/bonfire_common/lib/mix_tasks tasks" } else {"echo Link to bonfire_common to mix deps && just deps-get && ln -sf ../../deps/bonfire_common/lib/mix_tasks tasks"} }}

@rand:
	echo {{ uuid() }}-{{ uuid() }}-{{ uuid() }}-{{ uuid() }}
# note: doesn't work in github CI ^

# Start or stop nix postgres server
@nix-db pg_cmd:
  pg_ctl -D ${PGDATA} -l ${PGDATA}/all.log -o "--unix_socket_directories='${PGDATA}'" $pg_cmd

# Initialize postgres database. Only need to run the first time!
nix-db-init: (nix-db "start")
  createdb ${PGDATABASE}
  createuser -dlsw ${PGUSERNAME}

# to test federation locally you can use `just dev-federate` or `just test-federation-live-DRAGONS`
# and run this in seperate terminal to start the above tunnel: `just tunnel`

tunnel: tunnel-localhost-run

@tunnel-localhost-run:
	echo "NOTE: you'll need to copy the generated domain name that will be printed below into HOSTNAME in your .env"
	ssh -R 80:localhost:4000 localhost.run

# this requires `cargo install tunnelto` (the homebrew version of tunnelto doesn't work)
@tunnel-tunnelto:
	echo "Opening tunnel on ${TUNNEL_SUBDOMAIN}.tunnelto.dev"
	tunnelto --subdomain $TUNNEL_SUBDOMAIN --port ${SERVER_PORT}

@local-tunnel-hostname:
	echo ${TUNNEL_DOMAIN}
#	echo "${TUNNEL_SUBDOMAIN}.tunnelto.dev"
# 	just tunnel-pyjamas

@tunnel-pyjamas:
	command -v wg-quick &> /dev/null || exit "You need to install Wireguard to run the tunnel/proxy. E.g. with: brew install wireguard-tools"
	([ -f tunnel.conf ] || curl https://tunnel.pyjam.as/{{PUBLIC_PORT}} > tunnel.conf) && (wg-quick up ./tunnel.conf || cat tunnel.conf) | pcregrep -o1 'https:\/\/([^/]+)'

@tunnel-pyjamas-down:
	wg-quick down ./tunnel.conf

with-docker-total:
	just with-docker-switch WITHOUT_DOCKER_TOTAL WITH_DOCKER_TOTAL
	
without-docker-total:
	just with-docker-switch WITH_DOCKER_TOTAL WITHOUT_DOCKER_TOTAL
	
with-docker-switch old_dir new_dir:
	mkdir -p data/{{ old_dir }} 
	mkdir -p data/{{ new_dir }} 
	mv _build data/{{ old_dir }} 
	mv assets/node_modules data/{{ old_dir }} 
	mv data/{{ new_dir }}/_build ./ 
	mv data/{{ new_dir }}/node_modules assets/

cloudron-secrets-generate location:
	cloudron env set --app {{location}} SECRET_KEY_BASE="$(just rand)"
	cloudron env set --app {{location}} SIGNING_SALT="$(just rand)"
	cloudron env set --app {{location}} ENCRYPTION_SALT="$(just rand)"
