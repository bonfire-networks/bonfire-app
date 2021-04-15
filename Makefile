.PHONY: setup updates db-reset build dev shell

LIBS_PATH=./forks/
ORG_NAME=bonfirenetworks
APP_FLAVOUR ?= `git name-rev --name-only HEAD`
APP_NAME=bonfire-$(APP_FLAVOUR)
UID := $(shell id -u)
GID := $(shell id -g)
APP_REL_CONTAINER="$(ORG_NAME)_$(APP_NAME)_release"
APP_REL_DOCKERFILE=Dockerfile.release
APP_REL_DOCKERCOMPOSE=docker-compose.release.yml
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
APP_BUILD ?= `git rev-parse --short HEAD`
APP_DOCKER_REPO="$(ORG_NAME)/$(APP_NAME)"

export UID
export GID

init:
	@echo "Light that fire... $(APP_NAME):$(APP_VSN)-$(APP_BUILD)"
	@mkdir -p config/prod
	@mkdir -p config/dev
	@cp -n config/templates/public.env config/dev/ | true
	@cp -n config/templates/public.env config/prod/ | true
	@cp -n config/templates/not_secret.env config/dev/secrets.env | true
	@cp -n config/templates/not_secret.env config/prod/secrets.env | true
	@mkdir -p forks/
	@touch deps.path
	@mkdir -p data/uploads/

help: init
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	
mix-%: init ## Run a specific mix command, eg: `make mix-deps.get` or make mix-deps.update args="pointers"
	docker-compose run web mix $* $(args)

setup: build mix-setup ## First run - prepare environment and dependencies

db:
	docker-compose run db 

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

update: init pull bonfire-pre-updates ## Update/prepare dependencies, without Docker
	mix upgrade
	make bonfire-post-updates 
	make deps-all-git-pull 

d-update: init pull build bonfire-pre-updates mix-upgrade bonfire-post-updates deps-all-git-pull ## Update/prepare dependencies, using Docker

bonfire-pre-update:
	mv deps.path deps.path.disabled 2> /dev/null || echo "continue"

bonfire-pre-updates: bonfire-pre-update
	# rm -rf deps/pointers*
	# rm -rf deps/bonfire*
	# rm -rf deps/cpub*
	# rm -rf deps/activity_pu*

bonfire-updates: init bonfire-pre-updates
	docker-compose run web mix bonfire.deps
	make bonfire-post-updates

bonfire-post-updates:
	mv deps.path.disabled deps.path  2> /dev/null || echo "continue"

bonfire-push-all-updates: deps-all-git-commit-push bonfire-push-app-updates

bonfire-push-app-updates: bonfire-pre-updates
	git add .
	git commit -a
	git pull --rebase
	mix updates 
	make bonfire-post-updates
	make git-publish

d-bonfire-push-all-updates: deps-all-git-commit-push d-bonfire-push-app-updates

d-bonfire-push-app-updates: bonfire-pre-updates
	git add .
	git commit -a
	git pull --rebase
	make mix-updates 
	make bonfire-post-updates
	make git-publish
	make dev

git-publish:
	./git-publish.sh

dep-hex-%: init ## add/enable/disable/delete a hex dep with messctl command, eg: `make dep-hex-enable dep=pointers version="~> 0.2"
	docker-compose run web messctl $* $(dep) $(version) deps.hex

dep-git-%: init ## add/enable/disable/delete a git dep with messctl command, eg: `make dep-hex-enable dep=pointers repo=https://github.com/bonfire-networks/pointers#main
	docker-compose run web messctl $* $(dep) $(repo) deps.git

dep-local-%: init ## add/enable/disable/delete a local dep with messctl command, eg: `make dep-hex-enable dep=pointers path=./libs/pointers
	docker-compose run web messctl $* $(dep) $(path) deps.path

dep-clone-local: ## Clone a git dep and use the local version, eg: make dep-clone-local dep="bonfire_me" repo=https://github.com/bonfire-networks/bonfire_me
	git clone $(repo) $(LIBS_PATH)$(dep) 2> /dev/null || (cd $(LIBS_PATH)$(dep) ; git pull)
	make dep-go-local dep=$(dep)

dep-clone-local-all: ## Clone all bonfire deps / extensions
	@curl -s https://api.github.com/orgs/bonfire-networks/repos?per_page=500 | ruby -rrubygems -e 'require "json"; JSON.load(STDIN.read).each { |repo| %x[make dep-clone-local dep="#{repo["name"]}" repo="#{repo["ssh_url"]}" ]}'

deps-all-git-commit-push:
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

deps.get: init bonfire-pre-update
	docker-compose run web mix deps.get
	make bonfire-post-updates

deps.update.all: 
	make deps.update-"--all"

deps.update-%: init bonfire-pre-update
	docker-compose run web mix deps.update $*
	make bonfire-post-updates  	

dev: init docker-stop-web ## Run the app with Docker
	# docker-compose --verbose run --name bonfire_web --service-ports web
	docker-compose run --name bonfire_web --service-ports web

dev-bg: init docker-stop-web ## Run the app in dev mode, in the background
	docker-compose run --detach --name bonfire_web --service-ports web elixir -S mix phx.server

docker-stop-web: 
	@docker stop bonfire_web 2> /dev/null || true
	@docker rm bonfire_web 2> /dev/null || true

git-forks-add: ## Run a git command on each fork
	find $(LIBS_PATH) -mindepth 1 -maxdepth 1 -type d -exec echo add {} \; -exec git -C '{}' add . \;

git-forks-%: ## Run a git command on each fork
	find $(LIBS_PATH) -mindepth 1 -maxdepth 1 -type d -exec echo $* {} \; -exec git -C '{}' $* \;

git-merge-%: ## Draft-merge another branch, eg `make git-merge-with-valueflows-api` to merge branch `with-valueflows-api` into the current one
	git merge --no-ff --no-commit $*

test: init ## Run tests
	docker-compose run web mix test $(args)

licenses: init bonfire-pre-update
	docker-compose run web mix licenses
	make bonfire-post-updates

cmd-%: init ## Run a specific command in the container, eg: `make cmd-messclt` or `make cmd-"messctl help"` or `make cmd-messctl args="help"`
	docker-compose run web $* $(args)


assets-prepare:
	cp lib/*/*/overlay/* rel/overlays/ 2> /dev/null || true

rel-build-no-cache: init assets-prepare ## Build the Docker image
	docker build \
		--no-cache \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg APP_BUILD=$(APP_BUILD) \
		-t $(APP_DOCKER_REPO):$(APP_VSN)-release-$(APP_BUILD) \
		-f $(APP_REL_DOCKERFILE) .
	@echo Build complete: $(APP_DOCKER_REPO):$(APP_VSN)-release-$(APP_BUILD)

rel-build: init assets-prepare ## Build the Docker image using previous cache
	docker build \
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