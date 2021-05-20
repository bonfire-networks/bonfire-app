.PHONY: setup updates db-reset build dev shell

BASH := $(shell which bash)

# what flavour do we want?
FLAVOUR ?= classic
BONFIRE_FLAVOUR ?= flavours/$(FLAVOUR)

LIBS_PATH ?= ./forks/
ORG_NAME ?= bonfirenetworks
APP_NAME ?= bonfire-$(FLAVOUR)
UID := $(shell id -u)
GID := $(shell id -g)
APP_REL_CONTAINER="$(ORG_NAME)_$(APP_NAME)_release"
APP_REL_DOCKERFILE=Dockerfile.release
APP_REL_DOCKERCOMPOSE=docker-compose.release.yml
APP_VSN ?= `grep -m 1 'version:' mix.exs | cut -d '"' -f2`
APP_BUILD ?= `git rev-parse --short HEAD`
APP_DOCKER_REPO="$(ORG_NAME)/$(APP_NAME)"

export UID
export GID

define setup_env
	$(eval ENV_DIR := $(BONFIRE_FLAVOUR)/config/$(1))
	@echo "Loading environment variables from $(ENV_DIR)"
	@$(call load_env,$(ENV_DIR)/public.env)
	@$(call load_env,$(ENV_DIR)/secrets.env)
endef
define load_env
	$(eval ENV_FILE := $(1))
	# @echo "Loading env vars from $(ENV_FILE)"
	$(eval include $(ENV_FILE)) # import env into make
	$(eval export) # export env from make
endef
	
init:
	@ln -sfn $(BONFIRE_FLAVOUR)/config ./config
	@mkdir -p config/prod
	@mkdir -p config/dev
	@touch config/deps.path
	@cp -n config/templates/public.env config/dev/ | true
	@cp -n config/templates/public.env config/prod/ | true
	@cp -n config/templates/not_secret.env config/dev/secrets.env | true
	@cp -n config/templates/not_secret.env config/prod/secrets.env | true
	@$(call setup_env,dev)
	@echo "Light that fire... $(APP_NAME) with $(FLAVOUR) flavour $(APP_VSN) - $(APP_BUILD)"
	@mkdir -p forks/
	@mkdir -p data/uploads/
	@mkdir -p data/search/dev

help: init
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	
mix-%: init ## Run a specific mix command, eg: `make mix-deps.get` or make mix-deps.update args="pointers"
	docker-compose run web mix $* $(args)

setup: build mix-setup ## First run - prepare environment and dependencies

db:
	docker-compose up -d db search 

db-pre-migrations:
	touch deps/*/lib/migrations.ex 2> /dev/null || echo "continue"
	touch forks/*/lib/migrations.ex 2> /dev/null || echo "continue"
	touch priv/repo/* 2> /dev/null || echo "continue"

db-reset: db-pre-migrations mix-ecto.reset ## Reset the DB

db-rollback: ## Rollback last DB migration
	make mix-"ecto.rollback" 

db-rollback-all: ## Rollback ALL DB migrations
	make mix-"ecto.rollback --all" 

test-db-reset: db-pre-migrations ## Create or reset the test DB
	docker-compose run -e MIX_ENV=test web mix ecto.reset

build: init ## Build the docker image
	docker-compose build

shell: init ## Open a shell, in dev mode
	docker-compose run --service-ports web bash

pull: 
	git pull

update: init pull  ## Update/prepare dependencies, without Docker
	WITH_FORKS=0 mix updates
	make deps-all-git-pull 
	mix deps.get
	mix ecto.migrate

d-update: init pull build  ## Update/prepare dependencies, using Docker
	docker-compose run -e WITH_FORKS=0 web mix updates 
	make deps-all-git-pull 
	make mix-deps.get
	make mix-ecto.migrate 

bonfire-updates: init 
	docker-compose run -e WITH_FORKS=0 web mix bonfire.deps
	
bonfire-push-all-updates: deps-all-git-commit-push bonfire-push-app-updates

bonfire-push-release: deps-all-git-commit-push bonfire-push-app-release

bonfire-app-updates: 
	git add --all .
	git diff-index --quiet HEAD || git commit --all
	git pull --rebase
	WITH_FORKS=0 mix updates

bonfire-push-app-updates: bonfire-app-updates
	make git-publish

bonfire-push-app-release: bonfire-app-updates
	cd lib/mix/tasks/release/ && mix escript.build && ./release ../../../../ alpha
	make git-publish

bonfire-deps-updates: 
	git pull --rebase
	WITH_FORKS=0 mix updates 
	make git-publish

d-bonfire-push-all-updates: deps-all-git-commit-push d-bonfire-push-app-updates

d-bonfire-push-app-updates: 
	git add .
	git commit -a
	git pull --rebase
	docker-compose run -e WITH_FORKS=0 web mix updates 
	make git-publish
	make dev

git-publish:
	chmod +x git-publish.sh
	./git-publish.sh

dep-hex-%: init ## add/enable/disable/delete a hex dep with messctl command, eg: `make dep-hex-enable dep=pointers version="~> 0.2"
	docker-compose run web messctl $* $(dep) $(version) config/deps.hex

dep-git-%: init ## add/enable/disable/delete a git dep with messctl command, eg: `make dep-hex-enable dep=pointers repo=https://github.com/bonfire-networks/pointers#main
	docker-compose run web messctl $* $(dep) $(repo) config/deps.git

dep-local-%: init ## add/enable/disable/delete a local dep with messctl command, eg: `make dep-hex-enable dep=pointers path=./libs/pointers
	docker-compose run web messctl $* $(dep) $(path) config/deps.path

dep-clone-local: ## Clone a git dep and use the local version, eg: make dep-clone-local dep="bonfire_me" repo=https://github.com/bonfire-networks/bonfire_me
	git clone $(repo) $(LIBS_PATH)$(dep) 2> /dev/null || (cd $(LIBS_PATH)$(dep) ; git pull)
	make dep-go-local dep=$(dep)

dep-clone-local-all: ## Clone all bonfire deps / extensions
	@curl -s https://api.github.com/orgs/bonfire-networks/repos?per_page=500 | ruby -rrubygems -e 'require "json"; JSON.load(STDIN.read).each { |repo| %x[make dep-clone-local dep="#{repo["name"]}" repo="#{repo["ssh_url"]}" ]}'

deps-all-git-commit-push:
	chmod +x git-publish.sh
	find $(LIBS_PATH) -mindepth 1 -maxdepth 1 -type d -exec ./git-publish.sh {} \;
	# make deps-all-git-add
	# make deps-all-git-commit
	# make deps-all-git-pull
	# make deps-all-git-push

deps-all-git-%: ## runs a git command (eg. `make deps-all-git-pull` pulls the latest version of all local deps from its git remote
	# chown -R $$USER ./forks
	make git-forks-"config core.fileMode false"
	make git-forks-$*

deps-prepare-push:
	mv deps.path deps.path.disabled

dep-go-local: ## Switch to using a standard local path, eg: make dep-go-local dep=pointers
	make dep-go-local-path dep=$(dep) path=$(LIBS_PATH)$(dep)

dep-go-local-%: ## Switch to using a standard local path, eg: make dep-go-local dep=pointers
	make dep-go-local dep="$*"

dep-go-local-path: ## Switch to using a local path, eg: make dep-go-local dep=pointers path=./libs/pointers
	make dep-local-add dep=$(dep) path=$(path)
	make dep-local-enable dep=$(dep) path=""
	# make dep-git-disable dep=$(dep) repo="" 
	# make dep-hex-disable dep=$(dep) version=""

dep-go-git: ## Switch to using a git repo, eg: make dep-go-git dep="pointers" repo=https://github.com/bonfire-networks/pointers (repo is optional if previously specified)
	make dep-git-add dep=$(dep) $(repo) 2> /dev/null || true
	make dep-git-enable dep=$(dep) repo=""
	make dep-hex-disable dep=$(dep) version=""
	make dep-local-disable dep=$(dep) path=""

dep-go-hex: ## Switch to using a library from hex.pm, eg: make dep-go-hex dep="pointers" version="~> 0.2" (version is optional if previously specified)
	make dep-hex-add dep=$(dep) version=$(version) 2> /dev/null || true
	make dep-hex-enable dep=$(dep) version=""
	make dep-git-disable dep=$(dep) repo=""
	make dep-local-disable dep=$(dep) path=""

deps.get: init 
	docker-compose run -e WITH_FORKS=0 web mix deps.get
	make mix-"deps.get"

deps.update.all: 
	make deps.update-"--all"

deps.update-%: init 
	docker-compose run -e WITH_FORKS=0 web mix deps.update $*

dev: init docker-stop-web ## Run the app with Docker
	docker-compose --verbose run --name bonfire_web --service-ports web
	#docker-compose run --name bonfire_web --service-ports web

dev-bg: init docker-stop-web ## Run the app in dev mode, in the background
	docker-compose run --detach --name bonfire_web --service-ports web elixir -S mix phx.server

docker-stop-web: 
	@docker stop bonfire_web 2> /dev/null || true
	@docker rm bonfire_web 2> /dev/null || true

git-forks-add: ## Run a git command on each fork
	find $(LIBS_PATH) -mindepth 1 -maxdepth 1 -type d -exec echo add {} \; -exec git -C '{}' add . \;

git-forks-%: ## Run a git command on each fork
	find $(LIBS_PATH) -mindepth 1 -maxdepth 1 -type d -exec echo $* {} \; -exec git -C '{}' $* \;

deps-git-fix: ## Run a git command on each dep, to ignore chmod changes
	find ./deps -mindepth 1 -maxdepth 1 -type d -exec git -C '{}' config core.fileMode false \;

git-merge-%: ## Draft-merge another branch, eg `make git-merge-with-valueflows-api` to merge branch `with-valueflows-api` into the current one
	git merge --no-ff --no-commit $*

git-conflicts:
	find $(LIBS_PATH) -mindepth 1 -maxdepth 1 -type d -exec echo add {} \; -exec git -C '{}' diff --name-only --diff-filter=U \;

test: init ## Run tests
	docker-compose run web mix test $(args)

test-remote: init ## Run tests (ignoring local forks)
	docker-compose run -e WITH_FORKS=0 web mix test $(args)

licenses: init 
	docker-compose run -e WITH_FORKS=0 web mix licenses
	

cmd-%: init ## Run a specific command in the container, eg: `make cmd-messclt` or `make cmd-"messctl help"` or `make cmd-messctl args="help"`
	docker-compose run web $* $(args)


assets-prepare:
	cp lib/*/*/overlay/* rel/overlays/ 2> /dev/null || true

config-prepare: # copy current flavour's config, without using symlinks
	cp -rfL $(BONFIRE_FLAVOUR)/config ./data/config

rel-build-no-cache: init config-prepare assets-prepare ## Build the Docker image
	docker build \
		--no-cache \
		--build-arg BONFIRE_FLAVOUR=config \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t $(APP_DOCKER_REPO):$(APP_VSN)-release-$(APP_BUILD) \
		-f $(APP_REL_DOCKERFILE) .
	@echo Build complete: $(APP_DOCKER_REPO):$(APP_VSN)-release-$(APP_BUILD)

rel-build: init config-prepare assets-prepare ## Build the Docker image using previous cache
	docker build \
		--build-arg BONFIRE_FLAVOUR=config \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t $(APP_DOCKER_REPO):$(APP_VSN)-release-$(APP_BUILD) \
		-f $(APP_REL_DOCKERFILE) .
	@echo Build complete: $(APP_DOCKER_REPO):$(APP_VSN)-release-$(APP_BUILD) 
	@echo "Remember to run make rel-tag-latest or make rel-push"

rel-tag-latest: init ## Add latest tag to last build
	@docker tag $(APP_DOCKER_REPO):$(APP_VSN)-release-$(APP_BUILD) $(APP_DOCKER_REPO):latest

rel-push: init ## Add latest tag to last build and push to Docker Hub
	@docker push $(APP_DOCKER_REPO):latest

rel-run: init docker-stop-web ## Run the app in Docker & starts a new `iex` console
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) run --name bonfire_web --service-ports --rm backend bin/bonfire start_iex

rel-run-bg: init docker-stop-web ## Run the app in Docker, and keep running in the background
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) up -d

rel-stop: ## Run the app in Docker, and keep running in the background
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) stop

rel-shell: docker-stop-web ## Runs a simple shell inside of the container, useful to explore the image
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) run --name bonfire_web --service-ports --rm backend /bin/bash

fire: init db
	iex -S mix phx.server

sparks: init db
	mix test $(only)
