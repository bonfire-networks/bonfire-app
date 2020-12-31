.PHONY: setup updates db-reset build dev shell

LIBS_PATH=./forks/

mix-%: ## Run a specific mix command, eg: `make mix-deps.get` or make mix-deps.update args="pointers"
	docker-compose run web mix $* $(args)

setup: build mix-setup ## First run - prepare environment and dependencies

db-reset: mix-ecto.reset ## Reset the DB

test-db-reset: ## Create or reset the test DB
	docker-compose run -e MIX_ENV=test web mix ecto.reset

build: ## Build the docker image
	docker-compose build

shell: ## Open a shell, in dev mode
	docker-compose run --service-ports web bash

pull: 
	git pull

update: pull build deps-local-git-pull bonfire-pre-updates mix-updates bonfire-post-updates ## Update/prepare dependencies

bonfire-pre-update:
	mv deps.path deps.path.disabled 2> /dev/null || echo "continue"

bonfire-pre-updates: bonfire-pre-update
	sudo rm -rf deps/pointers*
	sudo rm -rf deps/bonfire*
	sudo rm -rf deps/cpub*
	sudo rm -rf deps/activity_pu*

bonfire-updates: bonfire-pre-updates
	docker-compose run web mix bonfire.deps
	make bonfire-post-updates

bonfire-post-updates:
	mv deps.path.disabled deps.path  2> /dev/null || echo "continue"

bonfire-push-all-updates: deps-local-commit-push bonfire-push-app-updates

bonfire-push-app-updates: 
	mv deps.path deps.path.disabled 2> /dev/null || echo "continue"
	make update 2> /dev/null || echo "continue"
	make bonfire-post-updates
	git pull
	git add .
	git commit
	git push

dep-hex-%: ## add/enable/disable/delete a hex dep with messctl command, eg: `make dep-hex-enable dep=pointers version="~> 0.2"
	docker-compose run web messctl $* $(dep) $(version) deps.hex

dep-git-%: ## add/enable/disable/delete a git dep with messctl command, eg: `make dep-hex-enable dep=pointers repo=https://github.com/bonfire-ecosystem/pointers#main
	docker-compose run web messctl $* $(dep) $(repo) deps.git

dep-local-%: ## add/enable/disable/delete a local dep with messctl command, eg: `make dep-hex-enable dep=pointers path=./libs/pointers
	docker-compose run web messctl $* $(dep) $(path) deps.path

dep-clone-local: ## Clone a git dep and use the local version, eg: make dep-clone-local dep="bonfire_me" repo=https://github.com/bonfire-ecosystem/bonfire_me
	git clone $(repo) $(LIBS_PATH)$(dep) 2> /dev/null || (cd $(LIBS_PATH)$(dep) ; git pull)
	make dep-go-local dep=$(dep)

deps-local-git-%: ## runs a git command (eg. `make deps-local-git-pull` pulls the latest version of all local deps from its git remote
	sudo chown -R $$USER ./forks
	find ./forks/ -maxdepth 1 -type d -exec git -C '{}' config core.fileMode false \;
	find ./forks/ -maxdepth 1 -type d -exec git -C '{}' $* \;

deps-local-commit-push:
	make deps-local-git-"add ."
	make deps-local-git-commit
	make deps-local-git-pull
	make deps-local-git-push

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

dep-go-git: ## Switch to using a git repo, eg: make dep-go-git dep="pointers" repo=https://github.com/bonfire-ecosystem/pointers (repo is optional if previously specified)
	make dep-git-add dep=$(dep) $(repo) 2> /dev/null || true
	make dep-git-enable dep=$(dep) repo=""
	make dep-hex-disable dep=$(dep) version=""
	make dep-local-disable dep=$(dep) path=""

dep-go-hex: ## Switch to using a library from hex.pm, eg: make dep-go-hex dep="pointers" version="~> 0.2" (version is optional if previously specified)
	make dep-hex-add dep=$(dep) version=$(version) 2> /dev/null || true
	make dep-hex-enable dep=$(dep) version=""
	make dep-git-disable dep=$(dep) repo=""
	make dep-local-disable dep=$(dep) path=""

deps.get: bonfire-pre-update
	docker-compose run web mix deps.get
	make bonfire-post-updates

deps.update.%: bonfire-pre-update
	docker-compose run web mix deps.update $*
	make bonfire-post-updates

deps.update.all: 
	make deps.update --all

dev: ## Run the app with Docker
	docker-compose run --service-ports web

git-merge-%: ## Draft-merge another branch, eg `make git-merge-with-valueflows-api` to merge branch `with-valueflows-api` into the current one
	git merge --no-ff --no-commit $*

%: ## Run a specific mix command, eg: `make messclt` or `make "messctl help"` or make `messctl args="help"`
	docker-compose run web $* $(args)
