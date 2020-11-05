.PHONY: setup updates db-reset build dev shell

mix-%: ## Run a specific mix command, eg: `make mix-deps.get` or make mix-deps.update args="pointers"
	docker-compose run web mix $* $(args)

setup: build mix-setup ## First run - prepare environment and dependencies

updates: build mix-updates ## Update/prepare dependencies

db-reset: mix-ecto.reset ## Reset the DB

build: ## Build the docker image
	docker-compose build

shell: ## Open a shell, in dev mode
	docker-compose run --service-ports web bash

dep-%: ## Run a specific messctl command, eg: `make dep-help` or make dep-add args="pointers"
	docker-compose run --service-ports web messctl $* $(args)

dev: ## Run the app with Docker
	docker-compose run --service-ports web
