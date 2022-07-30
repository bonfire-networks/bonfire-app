# recipes for the `just` command runner: https://just.systems
# how to install: https://github.com/casey/just#packages

## Main configs - override these using env vars

# what flavour do we want?
FLAVOUR := env_var_or_default('FLAVOUR', "classic") 
FLAVOUR_PATH := env_var_or_default('FLAVOUR_PATH', "flavours/" + FLAVOUR) 

# do we want to use Docker? set as env var:
# - WITH_DOCKER=total : use docker for everything (default)
# - WITH_DOCKER=partial : use docker for services like the DB 
# - WITH_DOCKER=easy : use docker for services like the DB & compiled utilities like messctl 
# - WITH_DOCKER=no : please no
WITH_DOCKER := env_var_or_default('WITH_DOCKER', "total") 

MIX_ENV := env_var_or_default('MIX_ENV', "dev") 

## Other configs - edit these here if necessary
FORKS_PATH := "forks/"
ORG_NAME := "bonfirenetworks"
APP_NAME := "bonfire"
APP_VSN_EXTRA := "beta"
DB_DOCKER_IMAGE := env_var_or_default('DB_DOCKER_IMAGE', "postgis/postgis:12-3.2-alpine")  
APP_REL_DOCKERFILE :="Dockerfile.release"
APP_REL_DOCKERCOMPOSE :="docker-compose.release.yml"
APP_REL_CONTAINER := APP_NAME + "_release"
WEB_CONTAINER := APP_NAME +"_web"
APP_VSN := `grep -m 1 'version:' mix.exs | cut -d '"' -f2`
APP_BUILD := `git rev-parse --short HEAD`
APP_DOCKER_REPO := ORG_NAME+"/"+APP_NAME
CONFIG_PATH := FLAVOUR_PATH + "/config"
UID := `id -u`
GID := `id -g`

## Configure just
# choose shell for running recipes
set shell := ["bash", "-uc"]
# set shell := ["bash", "-uxc"] 
# load all vars from .env file
set dotenv-load
# export just vars into recipe as env vars
set export
# support args like $1, $2, etc, and $@ for all args
set positional-arguments


#### GENERAL SETUP RELATED COMMANDS ####

help:
	@echo "Just commands for Bonfire:"
	@just --list

pre-setup flavour='classic':
	@echo "Using flavour '$flavour' at flavours/$flavour with env '$MIX_ENV'"
	@ln -sfn flavours/$flavour/config ./config
	@mkdir -p data/
	@mkdir -p ./config/prod
	@mkdir -p ./config/dev
	@mkdir -p ./config/test
	@touch ./config/deps.path
	@test -f ./config/$MIX_ENV/.env || ((test -f ./config/$MIX_ENV/public.env && (cat ./config/$MIX_ENV/public.env ./config/$MIX_ENV/secrets.env > ./config/$MIX_ENV/.env) && rm ./config/$MIX_ENV/public.env && rm ./config/$MIX_ENV/secrets.env) || (cat ./config/templates/public.env ./config/templates/not_secret.env > ./config/$MIX_ENV/.env) && echo "MIX_ENV=$MIX_ENV" >> ./config/$MIX_ENV/.env)
	@ln -sf ./config/dev/ ./config/test/
	@rm .env | true
	@ln -sf ./config/$MIX_ENV/.env ./.env
	@mkdir -p forks/
	@mkdir -p data/uploads/
	@mkdir -p priv/static/data
	@ln -s data/uploads priv/static/data/ | true
	@mkdir -p data/search/dev
	@chmod 700 .erlang.cookie

# Initialise env files, and create some required folders, files and softlinks
config: 
	@just flavour $FLAVOUR

# Initialise a specific flavour, with its env files, and create some required folders, files and softlinks
flavour select_flavour: 
	@echo "Switching to flavour '$select_flavour'..."
	@just pre-setup $select_flavour
	@just deps-clean-data
	@just deps-clean-api
	@just js-deps-get
	@echo "You can now edit your config for flavour '$select_flavour' in /.env and ./config/ more generally."

pre-init:
	@echo "Running $MIX_ENV env, with flavour: $FLAVOUR at path: $FLAVOUR_PATH"
	@rm -rf ./priv/repo
	@cp -rn $FLAVOUR_PATH/repo ./priv/repo
	@rm -rf ./data/current_flavour
	@ln -sf ../$FLAVOUR_PATH ./data/current_flavour
	@ln -sf ./config/$MIX_ENV/.env ./.env

init: pre-init services
	@echo "Light that fire... $APP_NAME with $FLAVOUR flavour in $MIX_ENV - docker:$WITH_DOCKER - $APP_VSN - $APP_BUILD - $FLAVOUR_PATH - {{os_family()}}/{{os()}} on {{arch()}}"

#### COMMON COMMANDS ####

# First run - prepare environment and dependencies
setup: 
	just flavour $FLAVOUR
	just build
	just mix setup 

# Prepare environment and dependencies
prepare: 
	just pre-setup $FLAVOUR
	just build

# Run the app in development
dev: init dev-run 

@dev-run:
	{{ if WITH_DOCKER == "total" { "just docker-stop-web && docker-compose run --name $WEB_CONTAINER --service-ports web" } else { "iex -S mix phx.server" } }}

# Generate docs from code & readmes
docs: 
	just mix-remote docs

# Force the app to recompile
recompile: 
	just mix "compile --force"

dev-test: 
	@MIX_ENV=test START_SERVER=true just dev-run

# Run the app in dev mode, as a background service
dev-bg: init  
	{{ if WITH_DOCKER == "total" { "just docker-stop-web && docker-compose run --detach --name $WEB_CONTAINER --service-ports web elixir -S mix phx.server" } else { 'elixir --erl "-detached" -S mix phx.server" && echo "Running in background..." && (ps au | grep beam)' } }}

# Run latest database migrations (eg. after adding/upgrading an app/extension)
db-migrate: 
	just mix "ecto.migrate"

# Run latest database seeds (eg. inserting required data after adding/upgrading an app/extension)
db-seeds: db-migrate
	just mix "ecto.seeds"

# Reset the DB (caution: this means DATA LOSS)
db-reset: init dev-search-reset db-pre-migrations   
	just mix "ecto.reset"

dev-search-reset: dev-search-reset-docker
	rm -rf data/search/dev

dev-search-reset-docker:
	{{ if WITH_DOCKER != "no" { "docker-compose rm -s -v search" } else {""} }}

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
	just mix "ecto.migrate"
	just js-deps-get 

# Update the app and Bonfire extensions in ./deps
update-app: update-repo update-deps 

# Update Bonfire extensions in ./deps
update-deps: 
	@rm -rf deps/*/assets/pnpm-lock.yaml
	@rm -rf deps/*/assets/yarn.lock
	just mix-remote updates 

update-repo: pre-contrib-hooks
	@chmod +x git-publish.sh && ./git-publish.sh . pull || git pull

update-repo-pull: 
	@chmod +x git-publish.sh && ./git-publish.sh . pull only

# Update to the latest Bonfire extensions in ./deps 
update-deps-bonfire:  
	just mix-remote bonfire.deps

# Update evey single dependency (use with caution)
update-deps-all: 
	just mix-remote "deps.update --all"
	just deps-get

# Update a specify dep (eg. `just update.dep pointers`)
update-dep dep: 
	@chmod +x git-publish.sh && ./git-publish.sh $FORKS_PATH/$dep pull
	just mix-remote "deps.update $dep"
	./assets/install_extensions.sh $dep

# Pull the latest commits from all ./forks
update-forks: 
	@jungle git fetch || echo "Jungle not available, will fetch one by one instead."
	@chmod +x git-publish.sh && find $FORKS_PATH -mindepth 1 -maxdepth 1 -type d -exec ./git-publish.sh {} rebase \;
# TODO: run in parallel? find $FORKS_PATH -mindepth 1 -maxdepth 1 -type d | xargs -P 50 -I '{}' ./git-publish.sh '{}'

# Pull the latest commits from all ./forks
update-fork dep: 
	@chmod +x git-publish.sh && find $FORKS_PATH/$dep -mindepth 0 -maxdepth 0 -type d -exec ./git-publish.sh {} pull \;

# Fetch locked version of non-forked deps
deps-get: 
	just mix-remote deps.get
	just mix deps.get 
	just js-ext-deps-get

deps-clean: 
	just mix bonfire.deps.clean

deps-clean-data: 
	just mix bonfire.deps.clean.data

deps-clean-api: 
	just mix bonfire.deps.clean.api

#### DEPENDENCY & EXTENSION RELATED COMMANDS ####

js-deps-get: js-app-deps-get js-ext-deps-get

js-app-deps-get:
	chmod +x ./assets/install_app.sh
	just cmd ./assets/install_app.sh

js-ext-deps-get:
	chmod +x ./config/deps.js.sh
	just cmd ./config/deps.js.sh

deps-outdated:
	@just mix-remote "hex.outdated --all"

dep-clean dep:
	@just mix "deps.clean $dep --build" 

# Clone a git dep and use the local version, eg: `just dep-clone-local bonfire_me https://github.com/bonfire-networks/bonfire_me`
dep-clone-local dep repo: 
	git clone $repo $FORKS_PATH$dep 2> /dev/null || (cd $FORKS_PATH$dep ; git pull)
	just dep.go.local dep=$dep

# Clone all bonfire deps / extensions
deps-clone-local-all: 
	curl -s https://api.github.com/orgs/bonfire-networks/repos?per_page=500 | ruby -rrubygems -e 'require "json"; JSON.load(STDIN.read).each { |repo| %x[just dep.clone.local dep="#{repo["name"]}" repo="#{repo["ssh_url"]}" ]}'

# Switch to using a local path, eg: just dep.go.local pointers
dep-go-local dep: 
	just dep-go-local-path $dep $FORKS_PATH$dep

# Switch to using a local path, specifying the path, eg: just dep.go.local dep=pointers path=./libs/pointers
dep-go-local-path dep path: 
	just dep-local add $dep $path
	just dep-local enable $dep $path

# Switch to using a git repo, eg: just dep.go.git pointers https://github.com/bonfire-networks/pointers (specifying the repo is optional if previously specified)
dep-go-git dep repo: 
	-just dep-git add $dep $repo 
	just dep-git enable $dep NA
	just dep-local disable $dep NA

# Switch to using a library from hex.pm, eg: just dep.go.hex dep="pointers" version="_> 0.2" (specifying the version is optional if previously specified)
dep-go-hex dep version: 
	-just dep-hex add dep=$dep version=$version 
	just dep-hex enable $dep NA
	just dep-git disable $dep NA
	just dep-local disable $dep NA

# add/enable/disable/delete a hex dep with messctl command, eg: `just dep-hex enable pointers 0.2`
dep-hex command dep version: 
	just messctl "$command $dep $version"
	just mix "deps.clean $dep" 

# add/enable/disable/delete a git dep with messctl command, eg: `just dep-hex enable pointers https://github.com/bonfire-networks/pointers#main
dep-git command dep repo: 
	just messctl "$command $dep $repo config/deps.git"
	just mix "deps.clean $dep" 

# add/enable/disable/delete a local dep with messctl command, eg: `just dep-hex enable pointers ./libs/pointers`
dep-local command dep path: 
	just messctl "$command $dep $path config/deps.path"
	just mix "deps.clean $dep" 

# Utility to manage the deps in deps.hex, deps.git, and deps.path (eg. `just messctl help`)
messctl *args='': init 
	{{ if WITH_DOCKER == "no" { "messctl $@" } else { "docker-compose run web messctl $@" } }}

#### CONTRIBUTION RELATED COMMANDS ####

pre-push-hooks: pre-contrib-hooks
	just mix changelog

pre-contrib-hooks: 
# 	@sed -i '' 's,/forks/,/deps/,' config/deps_hooks.js

# Push all changes to the app and extensions in ./forks
contrib-forks: pre-push-hooks contrib-forks-publish git-publish 

# Push all changes to the app and extensions in ./forks, increment the app version number, and push a new version/release
contrib-release: pre-push-hooks contrib-forks-publish update-app contrib-app-release

# Rebase app's repo and push all changes to the app
contrib-app-only: pre-push-hooks update-repo git-publish 

# Increment the app version number and commit/push
contrib-app-release: pre-push-hooks contrib-app-release-increment git-publish 

# Increment the app version number 
contrib-app-release-increment: 
	@cd lib/mix/tasks/release/ && mix escript.build && ./release ../../../../ $APP_VSN_EXTRA

contrib-forks-publish: update-forks

# Run the git add command on each fork
git-forks-add: deps-git-fix 
	find $FORKS_PATH -mindepth 1 -maxdepth 1 -type d -exec echo add {} \; -exec git -C '{}' add --all . \;

# Run a git status on each fork
git-forks-status: 
	@jungle git status || find $FORKS_PATH -mindepth 1 -maxdepth 1 -type d -exec echo {} \; -exec git -C '{}' status \;

# Run a git command on each fork (eg. `just git-forks pull` pulls the latest version of all local deps from its git remote
git-forks command: 
	@find $FORKS_PATH -mindepth 1 -maxdepth 1 -type d -exec echo $command {} \; -exec git -C '{}' $command \;

# List all diffs in forks
git-diff: 
	@find $FORKS_PATH -mindepth 1 -maxdepth 1 -type d -exec echo {} \; -exec git -C '{}' --no-pager diff --color --exit-code \;

# Run a git command on each dep, to ignore chmod changes
deps-git-fix: 
	find ./deps -mindepth 1 -maxdepth 1 -type d -exec git -C '{}' config core.fileMode false \;
	find ./forks -mindepth 1 -maxdepth 1 -type d -exec git -C '{}' config core.fileMode false \;

# Draft-merge another branch, eg `just git-merge with-valueflows-api` to merge branch `with-valueflows-api` into the current one
@git-merge branch: 
	git merge --no-ff --no-commit $branch

# Find any git conflicts in ./forks
@git-conflicts: 
	find $FORKS_PATH -mindepth 1 -maxdepth 1 -type d -exec echo add {} \; -exec git -C '{}' diff --name-only --diff-filter=U \;

@git-publish:
	chmod +x git-publish.sh
	./git-publish.sh

#### TESTING RELATED COMMANDS ####

# Run tests. You can also run only specific tests, eg: `just test forks/bonfire_social/test`
test *args='': 
	MIX_ENV=test just mix test $@

# Run only stale tests
test-stale *args='': 
	MIX_ENV=test just mix test --stale $@

# Run tests (ignoring changes in local forks)
test-remote *args='': 
	MIX_ENV=test just mix-remote test $@

# Run stale tests, and wait for changes to any module code, and re-run affected tests
test-watch *args='': 
	MIX_ENV=test just mix test.watch --stale $@

# Run stale tests, and wait for changes to any module code, and re-run affected tests, and interactively choose which tests to run
test-interactive *args='': 
	@MIX_ENV=test just mix test.interactive --stale $@

# dev-test-watch: init ## Run tests
# 	docker-compose run --service-ports -e MIX_ENV=test web iex -S mix phx.server

# Create or reset the test DB
test-db-reset: init db-pre-migrations 
	{{ if WITH_DOCKER == "total" { "docker-compose run -e MIX_ENV=test web mix ecto.reset" } else { "MIX_ENV=test mix ecto.reset" } }}


#### RELEASE RELATED COMMANDS (Docker-specific for now) ####
rel-init:
	MIX_ENV=prod just pre-init

# copy current flavour's config, without using symlinks
rel-config-prepare: 
	rm -rf data/current_flavour
	mkdir -p data
	rm -rf flavours/*/config/*/dev
	cp -rfL $FLAVOUR_PATH data/current_flavour

# copy current flavour's config, without using symlinks
rel-prepare: rel-config-prepare 
	mkdir -p forks/
	mkdir -p data/uploads/
	mkdir -p data/null/
	touch data/current_flavour/config/deps.path

# Build the Docker image (with no caching)
rel-rebuild: rel-init rel-prepare assets-prepare 
	just rel-build "forks/" --no-cache

# Build the Docker image (NOT including changes to local forks)
rel-build-release: rel-init rel-prepare assets-prepare 
	@echo "Please note that the build will not include any changes in forks/ that haven't been commited and pushed, you may want to run just contrib-release first."
	@just rel-build "data/null" --no-cache

# Build the Docker image (including changes to local forks, and using caching)
rel-build FORKS_TO_COPY_PATH="forks/" ARGS="": rel-init rel-prepare assets-prepare 
	@echo "Building $APP_NAME with flavour $FLAVOUR for arch {{arch()}}."
	@docker build $ARGS --progress=plain \
		--build-arg FLAVOUR_PATH=data/current_flavour \
		--build-arg APP_NAME=$APP_NAME \
		--build-arg APP_VSN=$APP_VSN \
		--build-arg APP_BUILD=$APP_BUILD \
		--build-arg FORKS_TO_COPY_PATH=$FORKS_TO_COPY_PATH \
		-t $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-$APP_BUILD  \
		-f $APP_REL_DOCKERFILE .
	@echo Build complete: $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-$APP_BUILD 
	@echo "Remember to run just rel-tag-latest or just rel-push"

rel-tag-commit build label: 
	@docker tag $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-{{build}}  $APP_DOCKER_REPO:{{label}}-$FLAVOUR-{{arch()}}

# Add latest tag to last build
rel-tag label='latest': 
	@docker tag $APP_DOCKER_REPO:release-$FLAVOUR-$APP_VSN-$APP_BUILD  $APP_DOCKER_REPO:{{label}}-$FLAVOUR-{{arch()}}

# Add latest tag to last build and push to Docker Hub
rel-push label='latest': 
	@just rel-tag {{label}}
	@just rel-push-only {{label}}

rel-push-only label='latest': 
	@docker login && docker push $APP_DOCKER_REPO:{{label}}-$FLAVOUR-{{arch()}}


# Run the app in Docker & starts a new `iex` console
rel-run: rel-init docker-stop-web rel-services
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE run --name $WEB_CONTAINER --service-ports --rm web bin/bonfire start_iex

# Run the app in Docker, and keep running in the background
rel-run-bg: rel-init docker-stop-web 
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE up -d

# Stop the running release
rel-stop: 
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE stop

rel-update: update-repo-pull
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE pull
	@echo Remember to run migrations on your DB...

rel-logs:
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE logs

# Stop the running release
rel-down: rel-stop 
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE down

# Runs a the app container and opens a simple shell inside of the container, useful to explore the image
rel-shell: rel-init docker-stop-web rel-services
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE run --name $WEB_CONTAINER --service-ports --rm web /bin/bash

# Runs a simple shell inside of the running app container, useful to explore the image
rel-shell-bg: rel-init rel-services
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE exec web /bin/bash

# Runs a simple shell inside of the DB container, useful to explore the image
rel-db-shell-bg: rel-init rel-services
	@docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE exec db /bin/bash

rel-db-dump: rel-init rel-services
	docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE exec db /bin/bash -c "PGPASSWORD=$POSTGRES_PASSWORD pg_dump --username $POSTGRES_USER $POSTGRES_DB" > data/db_dump.sql

rel-db-restore: rel-init rel-services
	cat $file | docker exec -i bonfire_release_db_1 /bin/bash -c "PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER $POSTGRES_DB"

rel-services: 
	{{ if WITH_DOCKER != "no" { "docker-compose -p $APP_REL_CONTAINER -f $APP_REL_DOCKERCOMPOSE up -d db search" } else {""} }}

#### DOCKER-SPECIFIC COMMANDS ####

# Start background docker services (eg. db and search backends).
@services: 
	{{ if MIX_ENV == "prod" { "just rel-services" } else { "just dev-services" } }}

@dev-services: 
	{{ if WITH_DOCKER != "no" { "docker-compose up -d db search" } else {""} }}

# Build the docker image
build: init 
	{{ if WITH_DOCKER != "no" { "mkdir -p deps && docker-compose pull && docker-compose build" } else { "echo Skip building container..." } }}

# Build the docker image
rebuild: init 
	{{ if WITH_DOCKER != "no" { "mkdir -p deps && docker-compose build --no-cache" } else { "echo Skip building container..." } }}

# Run a specific command in the container (if used), eg: `just cmd messclt` or `just cmd time` or `just cmd "echo hello"`
@cmd *args='': init 
	{{ if WITH_DOCKER == "total" { "docker-compose run --service-ports web $@" } else {"$@"} }}

# Open the shell of the web container, in dev mode
shell: 
	just cmd bash

docker-stop-web: 
	-docker stop $WEB_CONTAINER
	-docker rm $WEB_CONTAINER

#### MISC COMMANDS ####

# Run a specific mix command, eg: `just mix deps.get` or `just mix "deps.update pointers"`
@mix *args='': 
	just cmd mix $@

# Run a specific mix command, while ignoring any deps cloned into ./forks, eg: `just mix-remote deps.get` or `just mix-remote deps.update pointers`
mix-remote *args='': init 
	{{ if WITH_DOCKER == "total" { "docker-compose run -e WITH_FORKS=0 web mix $@" } else {"WITH_FORKS=0 mix $@"} }}

# Run a specific exh command, see https://github.com/rowlandcodes/exhelp
exh *args='': 
	just cmd "exh -S mix $@"

licenses:  
	@mkdir -p docs/DEPENDENCIES/
	just mix-remote licenses && mv DEPENDENCIES.md docs/DEPENDENCIES/$FLAVOUR.md

# Extract strings to-be-localised from the app and installed extensions
localise-extract: 
	just mix "bonfire.localise.extract"
	cd priv/localisation/ && for f in *.pot; do mv -- "$f" "${f%.pot}.po"; done

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

assets-prepare:
	-mkdir -p priv/static/data/uploads
	-mkdir -p rel/overlays/
	-cp lib/*/*/overlay/* rel/overlays/ 

# Workarounds for some issues running migrations
db-pre-migrations: 
	-touch deps/*/lib/migrations.ex
	-touch forks/*/lib/migrations.ex
	-touch priv/repo/*

# Generate secrets
secrets:
	@cd lib/mix/tasks/secrets/ && mix escript.build && ./secrets 128 3

# start or stop nix postgres server
nix-pg pg_cmd:
  @pg_ctl -D ${PGDATA} -l ${PGDATA}/all.log -o "--unix_socket_directories='${PGDATA}'" $pg_cmd

