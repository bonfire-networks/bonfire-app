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

APP_DOCKER_IMAGE := env_var_or_default('APP_DOCKER_IMAGE', APP_DOCKER_REPO+":latest-" +FLAVOUR)
DB_DOCKER_IMAGE := if arch() == "aarch64" { "ghcr.io/baosystems/postgis:12-3.3" } else { env_var_or_default('DB_DOCKER_IMAGE', "postgis/postgis:12-3.3-alpine") }
# DB_DOCKER_IMAGE := env_var_or_default('DB_DOCKER_IMAGE', "supabase/postgres")

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

setup:
	{{ if MIX_ENV == "prod" { "just setup-prod" } else { "just setup-dev" } }}

init services="db": _pre-init 
	@just services $services
	@echo "Light that fire! $APP_NAME with $FLAVOUR flavour in $MIX_ENV - docker:$WITH_DOCKER - $APP_VSN - $APP_BUILD - $FLAVOUR_PATH - {{os_family()}}/{{os()}} on {{arch()}}"

@config-basic select_flavour=FLAVOUR:
	echo "Setting up flavour '$select_flavour' in $MIX_ENV env..."
	just _pre-config $select_flavour
	just setup
	echo "Setup done."

@_pre-config select_flavour=FLAVOUR:
	rm -rf ./priv/repo/*
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
	chmod 644 .erlang.cookie

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


#### COMMON COMMANDS ####

setup-dev:
	just build
	just deps-clean-data
	just deps-clean-api
	just deps-clean-unused
	WITH_GIT_DEPS=0 just mix deps.get
	just _ln-spark-deps
	just deps-get

extension-post-install:
	just _ext-migrations-copy

_ext-migrations-copy:
	just mix bonfire.extension.copy_migrations --force

setup-prod:
	just build
	just deps-get --only prod
	just _deps-post-get

# Prepare environment and dependencies
prepare:
	just _pre-setup $FLAVOUR
	just build

# Run the app in development
@dev *args='':
	MIX_ENV=dev just dev-run "db" {{args}}

@dev-extra:
	iex --sname extra --remsh localenv

dev-run services="db" *args='': 
	@just init $services
	{{ if WITH_DOCKER == "total" { "just dev-docker $args" } else { "iex --sname localenv -S mix phx.server $args" } }}
# TODO: pass args to docker as well

@dev-remote: init
	{{ if WITH_DOCKER == "total" { "just dev-docker -e WITH_FORKS=0" } else { "WITH_FORKS=0 iex -S mix phx.server" } }}

@dev-app:
	just init db
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
	docker compose --profile $profile up -d
	docker logs bonfire_web -f

dev-profile-iex profile:
	docker compose --profile $profile exec web iex --sname extra --remsh localenv

dev-federate:
	FEDERATE=yes HOT_CODE_RELOAD=0 HOSTNAME=`just local-tunnel-hostname` PUBLIC_PORT=443 just dev

dev-docker *args='': docker-stop-web
	docker compose $args run -e HOT_CODE_RELOAD=0 --name $WEB_CONTAINER --service-ports web

# Generate docs from code & readmes
docs:
	just mix docs

# Analyse the codebase and generate some reports. Requires Graphviz and SQLite
arch:
	just mix arch.explore.static
	just mix arch.explore.xrefs
	just mix arch.explore.apps
	-MIX_ENV=test just mix arch.explore.coverage
	just mix arch.dsm
	just mix arch.report.html
	mkdir -p reports/dev/static/html/data/
	just mix arch.apps.xref --format mermaid --out reports/dev/static/html/data/apps.mermaid
	just mix arch.apps.xref --format svg --out reports/dev/static/html/data/apps.svg
# just mix arch.xref --format svg --out reports/dev/static/modules.png Bonfire.Web.Router Bonfire.UI.Social.Routes Bonfire.UI.Me.Routes

# Compile the app + extensions
compile *args='':
	just mix bonfire.extension.compile $args
	just mix compile $args

# Force the app + extensions to recompile
recompile *args='':
	just compile --force $args

dev-test:
	@MIX_ENV=test PHX_SERVER=yes just dev-run

# Run the app in dev mode, as a background service
dev-bg: init
	{{ if WITH_DOCKER == "total" { "just docker-stop-web && docker compose run --detach --name $WEB_CONTAINER --service-ports web elixir -S mix phx.server" } else { 'elixir --erl "-detached" -S mix phx.server" && echo "Running in background..." && (ps au | grep beam)' } }}

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
	DB_DOCKER_IMAGE=pgautoupgrade/pgautoupgrade:{{version}}-alpine PGAUTO_ONESHOT=yes docker compose up db 

db-dump-dev: 
	just services db
	just _db-dump docker-compose.yml 

dev-search-reset: dev-search-reset-docker
	rm -rf data/search/dev

dev-search-reset-docker:
	{{ if WITH_DOCKER != "no" { "docker compose rm -s -v search" } else {""} }}

# Rollback previous DB migration (caution: this means DATA LOSS)
db-rollback:
	just mix "ecto.rollback"

# Rollback ALL DB migrations (caution: this means DATA LOSS)
db-rollback-all:
	just mix "ecto.rollback --all"

#### UPDATE COMMANDS ####

# Update the dev app and all dependencies/extensions/forks, and run migrations
update: init update-repo
	just prepare
	just update-forks
	just update-deps
	just mix deps.get
	just _deps-post-get
	just js-deps-get
#   just mix compile
#	just db-migrate

# Update the app and Bonfire extensions in ./deps
update-app: update-repo update-deps

_pre-update-deps:
	@rm -rf deps/*/assets/pnpm-lock.yaml
	@rm -rf deps/*/assets/yarn.lock
	@rm -rf deps/bonfire/priv/repo

# Update Bonfire extensions in ./deps
update-deps: _pre-update-deps
	just mix-remote updates

update-repo: _pre-contrib-hooks
	@chmod +x git-publish.sh && ./git-publish.sh . pull || git pull

update-repo-pull:
	@chmod +x git-publish.sh && ./git-publish.sh . pull only

# Update to the latest Bonfire extensions in ./deps
update-deps-bonfire:
	just mix-remote bonfire.deps.update

# Update every single dependency (use with caution)
update-deps-all: _pre-update-deps
	just update-forks
	just mix-remote "deps.update --all"
	just _deps-post-get
	just update-deps-js
	just _assets-ln
	just js-ext-deps outdated
	-just mix "hex.outdated --all"

# Update every single dependency (use with caution)
update-deps-js: 
	just js-ext-deps
	just js-ext-deps upgrade

# Update a specify dep (eg. `just update.dep needle`)
update-dep dep: _pre-update-deps
	just update-fork $dep pull
	just mix-remote "deps.update $dep"
	just _deps-post-get
	./js-deps-get.sh $dep

# Pull the latest commits from all forks
@update-forks:
	(jungle git fetch && just update-forks-all rebase) || (echo "Jungle not available, will fetch one by one instead." && just update-forks-all pull)

update-forks-all cmd='pull':
	just update-fork-path $EXT_PATH $cmd
	just update-fork-path $EXTRA_FORKS_PATH $cmd

# Pull the latest commits from all forks
update-fork dep cmd='pull' mindepth='0' maxdepth='0':
	-just update-fork-path $EXT_PATH/$dep $cmd $mindepth $maxdepth
	-just update-fork-path $EXTRA_FORKS_PATH/$dep $cmd $mindepth $maxdepth

update-fork-path path cmd='pull' mindepth='0' maxdepth='1':
	@chmod +x git-publish.sh
	find $path -mindepth $mindepth -maxdepth $maxdepth -type d -exec ./git-publish.sh {} $cmd \;

# Fetch locked version of non-forked deps
@deps-get *args='':
	just mix deps.get $@
	-just mix-remote deps.get $@ || echo "Oops, could not download mix deps"
	just _deps-post-get
	just js-deps-get

@_deps-post-get: extension-post-install
	ln -sf ../../../priv/static extensions/bonfire/priv/static || ln -sf ../../../priv/static deps/bonfire/priv/static || echo "Could not find a priv/static dir to use"
	-cd deps/bonfire/priv && ln -sf ../../../priv/repo
	-cd extensions/bonfire/priv && ln -sf ../../../priv/repo
	mkdir -p priv/static/data
	mkdir -p data
	mkdir -p data/uploads
	-cd priv/static/data && ln -s ../../../data/uploads

deps-clean dep:
	just mix deps.clean $dep --build

@deps-clean-data:
	just mix bonfire.deps.clean.data

@deps-clean-api:
	just mix bonfire.deps.clean.api

@deps-clean-web:
	just deps-clean plug
	just deps-clean phoenix_html
	just deps-clean bonfire_ui_common

#### DEPENDENCY & EXTENSION RELATED COMMANDS ####

js-deps-get: js-ext-deps _assets-ln

@js-ext-deps yarn_args='':
	chmod +x ./config/deps.js.sh
	just cmd ./config/deps.js.sh $yarn_args

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
	git clone $repo $EXT_PATH$dep 2> /dev/null || (cd $EXT_PATH$dep ; git pull)
	just dep-go-local dep=$dep

# Clone all bonfire deps / extensions
deps-clone-local-all:
	curl -s https://api.github.com/orgs/bonfire-networks/repos?per_page=500 | ruby -rrubygems -e 'require "json"; JSON.load(STDIN.read).each { |repo| %x[just dep.clone.local dep="#{repo["name"]}" repo="#{repo["ssh_url"]}" ]}'

# Switch to using a local path, eg: just dep.go.local needle
dep-go-local dep:
	just dep-go-local-path $dep $EXT_PATH$dep

# Switch to using a local path, specifying the path, eg: just dep.go.local dep=needle path=./libs/needle
dep-go-local-path dep path:
	just dep-local add $dep $path
	just dep-local enable $dep $path

# Switch to using a git repo, eg: just dep.go.git needle https://github.com/bonfire-networks/needle (specifying the repo is optional if previously specified)
dep-go-git dep repo:
	-just dep-git add $dep $repo
	just dep-git enable $dep NA
	just dep-local disable $dep NA

# Switch to using a library from hex.pm, eg: just dep.go.hex dep="needle" version="_> 0.2" (specifying the version is optional if previously specified)
dep-go-hex dep version:
	-just dep-hex add dep=$dep version=$version
	just dep-hex enable $dep NA
	just dep-git disable $dep NA
	just dep-local disable $dep NA

# add/enable/disable/delete a hex dep with messctl command, eg: `just dep-hex enable needle 0.2`
dep-hex command dep version:
	just messctl "$command $dep $version"
	just mix "deps.clean $dep"

# add/enable/disable/delete a git dep with messctl command, eg: `just dep-hex enable needle https://github.com/bonfire-networks/needle
dep-git command dep repo:
	just messctl "$command $dep $repo config/deps.git"
	just mix "deps.clean $dep"

# add/enable/disable/delete a local dep with messctl command, eg: `just dep-hex enable needle ./libs/needle`
dep-local command dep path:
	just messctl "$command $dep $path config/deps.path"
	just mix "deps.clean $dep"

# Utility to manage the deps in deps.hex, deps.git, and deps.path (eg. `just messctl help`)
messctl *args='': init
	{{ if WITH_DOCKER == "no" { "messctl $@" } else { "docker compose run web messctl $@" } }}

#### CONTRIBUTION RELATED COMMANDS ####

_pre-push-hooks: _pre-contrib-hooks
	just mix format
	just icons-uniq
	just deps-clean bonfire
#	just mix changelog

_pre-contrib-hooks:
	-ex +%s,/extensions/,/deps/,e -scwq config/deps_hooks.js
	rm -rf forks/*/data/uploads/favicons/
	rm -rf extensions/*/data/uploads/favicons/
# -sed -i '' 's,/extensions/,/deps/,' config/deps_hooks.js

icons-uniq:
	sort -u -o assets/static/images/icons/icons.css assets/static/images/icons/icons.css

# Push all changes to the app and extensions in ./forks
contrib: _pre-push-hooks contrib-forks-publish git-publish

# Push all changes to the app and extensions in forks, increment the app version number, and push a new version/release
contrib-release: _pre-push-hooks contrib-forks-publish update contrib-app-release

# Rebase app's repo and push all changes to the app
contrib-app-only: _pre-push-hooks update-repo git-publish

# Increment the app version number and commit/push
contrib-app-release: _pre-push-hooks contrib-app-release-increment git-publish

# Increment the app version number
@contrib-app-release-increment:
	mkdir -p lib/mix
	cd lib/mix/ && (ln -sf ../../extensions/bonfire_common/lib/mix_tasks tasks || ln -sf ../../deps/bonfire_common/lib/mix_tasks tasks)
	cd lib/mix/tasks/release/ && mix escript.build && ./release ../../../../../ $APP_VSN_EXTRA

contrib-forks-publish: update-forks

contrib-rel-push: contrib-release rel-build-release rel-push

# Count lines of code (requires cloc: `brew install cloc`)
cloc:
	cloc lib config extensions/*/lib extensions/*/test test

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

@git-publish:
	chmod +x git-publish.sh
	./git-publish.sh

#### TESTING RELATED COMMANDS ####

# Run tests. You can also run only specific tests, eg: `just test extensions/bonfire_social/test`
test *args='':
	@echo "Testing $@..."
	MIX_ENV=test just mix test $@

# test-federation *args='':
# 	MIX_TEST_ONLY=federation just test --exclude ui backend --include federation $@

test-backend *args='':
	MIX_TEST_ONLY=backend just test --exclude ui --exclude federation --include backend $@

test-ui *args='':
	MIX_TEST_ONLY=ui just test --exclude backend --exclude federation --include ui $@

# Run only stale tests
test-stale *args='':
	@echo "Testing $@..."
	MIX_ENV=test just mix test --stale $@

# Run tests (ignoring changes in local forks)
test-remote *args='':
	@echo "Testing $@..."
	MIX_ENV=test just mix-remote test $@

# Run stale tests, and wait for changes to any module code, and re-run affected tests
test-watch *args='':
	@echo "Testing $@..."
	MIX_ENV=test just mix test.watch --stale $@

# Run stale tests, and wait for changes to any module code, and re-run affected tests, and interactively choose which tests to run
test-interactive *args='':
	@MIX_ENV=test just mix test.interactive --stale $@

ap_lib := "forks/activity_pub/test/activity_pub"
ap_integration := "extensions/bonfire_federate_activitypub/test/activity_pub_integration"
ap_boundaries := "extensions/bonfire_federate_activitypub/test/ap_boundaries"
ap_ext := "extensions/*/test/*federat* extensions/*/test/*/*federat* extensions/*/test/*/*/*federat*"
# ap_two := "forks/bonfire_federate_activitypub/test/dance"

test-federation: test-federation-dance-positions
	just test-stale {{ ap_lib }}
	just test-stale {{ ap_integration }}
	just test-stale {{ ap_ext }}
	just test-federation-dance-positions
	TEST_INSTANCE=yes just test-stale --only test_instance
	just test-federation-dance-positions

test-federation-lib *args=ap_lib: test-federation-dance-positions
	just test-watch $@

test-federation-bonfire *args=ap_integration: test-federation-dance-positions
	just test-watch $@

test-federation-boundaries *args="extensions/bonfire_federate_activitypub/test/boundaries": test-federation-dance-positions
	just test-watch $@

test-federation-in-extensions *args=ap_ext: test-federation-dance-positions
	just test-watch $@

test-federation-dance *args='': test-federation-dance-positions
	TEST_INSTANCE=yes just test --only test_instance $@
	just test-federation-dance-positions

test-federation-dance-unsigned *args='': test-federation-dance-positions
	ACCEPT_UNSIGNED_ACTIVITIES=1 TEST_INSTANCE=yes just test --only test_instance $@
	just test-federation-dance-positions

test-federation-dance-positions:
	TEST_INSTANCE=yes MIX_ENV=test just mix deps.clean bonfire --build

test-federation-live-DRAGONS *args='':
	FEDERATE=yes PHX_SERVER=yes HOSTNAME=`just local-tunnel-hostname` PUBLIC_PORT=443 just test --only live_federation $@

load_testing:
	TEST_INSTANCE=yes just mix bonfire.load_testing

# dev-test-watch: init ## Run tests
# 	docker compose run --service-ports -e MIX_ENV=test web iex -S mix phx.server

# Create or reset the test DB
test-db-reset: init db-pre-migrations
	{{ if WITH_DOCKER == "total" { "docker compose run -e MIX_ENV=test web mix ecto.drop --force" } else { "MIX_ENV=test just mix ecto.drop --force" } }}


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
	mkdir -p data/uploads/
	mkdir -p data/null/
	touch data/current_flavour/config/deps.path

# Build the Docker image (with no caching)
rel-rebuild:
	just rel-build {{EXT_PATH}} --no-cache

# Build the Docker image (NOT including changes to local forks)
rel-build-release ARGS="":
	@echo "Please note that the build will not include any changes in forks that haven't been committed and pushed, you may want to run just contrib-release first."
	@just rel-build remote {{ ARGS }}

# Build the release
rel-build USE_EXT="local" ARGS="":
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
	@echo "Building $APP_NAME with flavour $FLAVOUR for arch {{arch()}} with image $ELIXIR_DOCKER_IMAGE."
	@MIX_ENV=prod docker build {{ ARGS }} --progress=plain \
		--build-arg FLAVOUR=$FLAVOUR \
		--build-arg FLAVOUR_PATH=data/current_flavour \
		--build-arg ALPINE_VERSION=$ALPINE_VERSION \
		--build-arg ELIXIR_DOCKER_IMAGE=$ELIXIR_DOCKER_IMAGE \
		--build-arg FORKS_TO_COPY_PATH={{ FORKS_TO_COPY_PATH }} \
		-t $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-$APP_BUILD-{{arch()}}  \
		-f $APP_REL_DOCKERFILE .
	@echo Build complete, tagged as: $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-$APP_BUILD-{{arch()}}
	@echo "Remember to run just rel-tag or just rel-push"


# Add latest tag to last build
@rel-tag label='latest':
	just rel-tag-commit $APP_BUILD {{label}}

@rel-tag-commit build label='latest': _rel-init
	docker tag $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-{{build}}-{{arch()}} $APP_DOCKER_REPO:{{label}}-$FLAVOUR-{{arch()}}
	docker tag $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-{{build}}-{{arch()}} $APP_DOCKER_REPO_ALT:release-$FLAVOUR-$APP_VSN-{{build}}
	docker tag $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-{{build}}-{{arch()}} $APP_DOCKER_REPO_ALT:{{label}}-$FLAVOUR-{{arch()}}

# Add latest tag to last build and push to Docker Hub
rel-push label='latest':
	@just rel-tag {{label}}
	@echo just rel-push-only $APP_BUILD {{label}}
	@just rel-push-only $APP_BUILD {{label}}

rel-push-only build label='latest':
	@echo "Pushing to $APP_DOCKER_REPO"
	@docker login && docker push $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-{{build}}-{{arch()}} && docker push $APP_DOCKER_REPO:{{label}}-$FLAVOUR-{{arch()}}
# @just rel-push-only-alt {{build}} {{label}}

rel-push-only-alt build label='latest':
	@echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin
	@echo "Pushing to $APP_DOCKER_REPO_ALT"
	@docker push $APP_DOCKER_REPO_ALT:release-$FLAVOUR-$APP_VSN-{{build}}-{{arch()}} && docker push $APP_DOCKER_REPO_ALT:{{label}}-$FLAVOUR-{{arch()}}

# Run the app in Docker & starts a new `iex` console
rel-run services="db proxy": _rel-init docker-stop-web 
	just rel-services $services
	echo Run with Docker based on image $APP_DOCKER_IMAGE
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE run --name $WEB_CONTAINER --service-ports --rm web bin/bonfire start_iex

# Run the app in Docker, and keep running in the background
rel-run-bg services="db proxy": _rel-init docker-stop-web
	just rel-services $services
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE up -d

# Stop the running release
rel-stop:
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE stop

rel-update: update-repo-pull
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE pull
	@echo Remember to run migrations on your DB...

rel-logs:
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE logs

# Stop the running release
rel-down: rel-stop
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE down

# Runs a the app container and opens a simple shell inside of the container, useful to explore the image
rel-shell services="db proxy": _rel-init docker-stop-web 
	just rel-services $services
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE run --name $WEB_CONTAINER --service-ports --rm web /bin/bash

# Runs a simple shell inside of the running app container, useful to explore the image
rel-shell-bg services="db proxy": _rel-init 
	just rel-services $services
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE exec web /bin/bash

# Runs a simple shell inside of the DB container, useful to explore the image
rel-db-shell-bg: _rel-init 
	just rel-services db
	@docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE exec db /bin/bash

rel-db-dump: _rel-init 
	just rel-services db
	just _db-dump $APP_REL_DOCKERCOMPOSE "-p $APP_REL_CONTAINER"

rel-db-restore: _rel-init 
	just rel-services db
	cat $file | docker exec -i bonfire_release_db_1 /bin/bash -c "PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER $POSTGRES_DB"

rel-services services="db":
	{{ if WITH_DOCKER != "no" { "echo Starting docker services to run in the background: $services && docker compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE up -d $services" } else {""} }}

#### DOCKER-SPECIFIC COMMANDS ####

dc *args='':
	docker compose $@

# Start background docker services (eg. db and search backends).
@services services="db":
	{{ if MIX_ENV == "prod" { "just rel-services $services" } else { "just dev-services $services" } }}

@dev-services services="db":
	{{ if WITH_DOCKER != "no" { "(echo Starting docker services to run in the background: $services && docker compose up -d $services) || echo \"WARNING: You may want to make sure the docker daemon is started or run 'colima start' first.\"" } else { "echo Skipping docker services"} }}

# Build the docker image
@build: init
	mkdir -p deps
	{{ if WITH_DOCKER != "no" { "docker compose pull || echo Oops, could not download the Docker images!" } else { "just mix hex_setup" } }}
	{{ if WITH_DOCKER == "total" { "export $(./tool-versions-to-env.sh 3 | xargs) && export $(grep -v '^#' .tool-versions.env | xargs) && export ELIXIR_DOCKER_IMAGE=${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION} && docker compose build" } else { "echo ." } }}

# Build the docker image
rebuild: init
	{{ if WITH_DOCKER != "no" { "mkdir -p deps && docker compose build --no-cache" } else { "echo Skip building container..." } }}

_db-dump docker_compose compose_args="": 
	-mv data/db_dump.sql data/db_dump.archive.sql
	docker compose -f {{docker_compose}} {{compose_args}} exec db /bin/bash -c "PGPASSWORD=$POSTGRES_PASSWORD pg_dump --username $POSTGRES_USER $POSTGRES_DB" > data/db_dump.sql

# Run a specific command in the container (if used), eg: `just cmd messclt` or `just cmd time` or `just cmd "echo hello"`
@cmd *args='': init docker-stop-web
	{{ if WITH_DOCKER == "total" { "echo Run $@ in docker && docker compose run --name $WEB_CONTAINER --service-ports web $@" } else {" echo Run $@ && $@"} }}

cwd *args:
	cd {{invocation_directory()}}; $@

cwd-test *args:
	cd {{invocation_directory()}}; MIX_ENV=test mix test $@ 

# Open the shell of the web container, in dev mode
shell:
	just cmd bash

@docker-stop-web:
	-docker stop $WEB_CONTAINER
	-docker rm $WEB_CONTAINER

@docker *args='':
	docker $@

@docker-compose *args='':
	docker compose $@

#### MISC COMMANDS ####

# Open an interactive console
@imix *args='':
	just cmd iex -S mix $@

# Run a specific mix command, eg: `just mix deps.get` or `just mix "deps.update needle"`
@mix *args='':
	echo % mix $@
	{{ if MIX_ENV == "prod" { "just mix-maybe-prod $@" } else { "just cmd mix $@" } }}

@mix-eval *args='': init
	echo % mix eval "$@"
	{{ if MIX_ENV == "prod" {"echo Skip"} else { 'mix eval "$@"' } }}

@mix-maybe-prod *args='':
	{{ if WITH_DOCKER != "no" { "echo Ignoring mix commands when using docker in prod" } else { "just mix-maybe-prod-pre-release $@" } }}

@mix-maybe-prod-pre-release *args='':
	{{ if path_exists("./_build/prod/rel/bonfire/bin/bonfire")=="true" { "echo Ignoring mix commands since we already have a prod release (delete _build/prod/rel/bonfire/bin/bonfire if you want to build a new release)" } else { "just cmd mix $@" } }}

# Run a specific mix command, while ignoring any deps cloned into forks, eg: `just mix-remote deps.get` or `just mix-remote deps.update needle`
mix-remote *args='': init
	echo % WITH_FORKS=0 mix $@
	{{ if WITH_DOCKER == "total" { "docker compose run -e WITH_FORKS=0 web mix $@" } else {"WITH_FORKS=0 mix $@"} }}

xref-dot:
	just mix xref graph --format dot --include-siblings
	(awk '{if (!a[$0]++ && $1 != "}") print}' extensions/*/xref_graph.dot; echo }) > docs/xref_graph.dot
	dot -Tsvg docs/xref_graph.dot -o docs/xref_graph.svg

# Run a specific exh command, see https://github.com/rowlandcodes/exhelp
exh *args='':
	just cmd "exh -S mix $@"

licenses:
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
	{{ if path_exists("lib/mix/tasks")=="true" { "echo ." } else {"just ln-mix-tasks"} }}
	cd lib/mix/tasks/secrets/ && mix escript.build 
	./lib/mix/tasks/secrets/secrets --file .env
# ./lib/mix/tasks/secrets/secrets 128 3

@ln-mix-tasks:
	just mix deps.get
	cd lib/mix/ && {{ if path_exists("../../extensions/bonfire_common/lib/mix_tasks")=="true" { "ln -sf ../../extensions/bonfire_common/lib/mix_tasks tasks" } else {"ln -sf ../../deps/bonfire_common/lib/mix_tasks tasks"} }}

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

@docker-stop:
	docker compose stop
