.PHONY: setup updates db-reset build dev shell

LIBS_PATH=./forks/

mix-%: ## Run a specific mix command, eg: `make mix-deps.get` or make mix-deps.update args="pointers"
	docker-compose run web mix $* $(args)

setup: build mix-setup ## First run - prepare environment and dependencies

updates: build mix-updates ## Update/prepare dependencies

db-reset: mix-ecto.reset ## Reset the DB

build: ## Build the docker image
	docker-compose build

shell: ## Open a shell, in dev mode
	docker-compose run --service-ports web bash

dep-hex-%: ## add/enable/disable/delete a hex dep with messctl command, eg: `make dep-hex-enable dep=pointers version="~> 0.2"
	docker-compose run web messctl $* $(dep) $(version) deps.hex

dep-git-%: ## add/enable/disable/delete a git dep with messctl command, eg: `make dep-hex-enable dep=pointers repo=https://github.com/commonspub/pointers#main
	docker-compose run web messctl $* $(dep) $(repo) deps.git

dep-local-%: ## add/enable/disable/delete a local dep with messctl command, eg: `make dep-hex-enable dep=pointers path=./libs/pointers
	docker-compose run web messctl $* $(dep) $(path) deps.path

dep-clone-local: ## Clone a git dep and use the local version, eg: make dep-clone-local dep="pointers" repo=https://github.com/commonspub/pointers
	git clone $(repo) $(LIBS_PATH)$(dep) 2> /dev/null || (cd $(LIBS_PATH)$(dep) ; git pull)
	make dep-go-local dep=$(dep)

dep-go-local: ## Switch to using a standard local path, eg: make dep-go-local dep=pointers
	make dep-go-local-path dep=$(dep) path=$(LIBS_PATH)$(dep)

dep-go-local-%: ## Switch to using a standard local path, eg: make dep-go-local dep=pointers
	make dep-go-local dep="$*"

dep-go-local-path: ## Switch to using a local path, eg: make dep-go-local dep=pointers path=./libs/pointers
	make dep-local-add dep=$(dep) path=$(path)
	make dep-local-enable dep=$(dep) path=""
	# make dep-git-disable dep=$(dep) repo="" 
	# make dep-hex-disable dep=$(dep) version=""

dep-go-git: ## Switch to using a git repo, eg: make dep-go-git dep="pointers" repo=https://github.com/commonspub/pointers (repo is optional if previously specified)
	make dep-git-add dep=$(dep) $(repo) 2> /dev/null || true
	make dep-git-enable dep=$(dep) repo=""
	make dep-hex-disable dep=$(dep) version=""
	make dep-local-disable dep=$(dep) path=""

dep-go-hex: ## Switch to using a library from hex.pm, eg: make dep-go-hex dep="pointers" version="~> 0.2" (version is optional if previously specified)
	make dep-hex-add dep=$(dep) version=$(version) 2> /dev/null || true
	make dep-hex-enable dep=$(dep) version=""
	make dep-git-disable dep=$(dep) repo=""
	make dep-local-disable dep=$(dep) path=""

dev: ## Run the app with Docker
	docker-compose run --service-ports web

%: ## Run a specific mix command, eg: `make messclt` or `make "messctl help"` or make `messctl args="help"`
	docker-compose run web $* $(args)
