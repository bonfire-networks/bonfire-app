.PHONY: setup updates db-reset build dev

mix-%: ## Run a specific mix command in Docker Dev, eg: `make mix-deps.get` or make mix-deps.update args="pointers"
	docker-compose run web mix $* $(args)

setup: build mix-setup ## First run - prepare Docker Dev environment and dependencies

updates: build mix-updates ## Update/prepare Docker Dev dependencies

db-reset: mix-ecto.reset ## Reset the DB

build: ## Build the docker image
	docker-compose build

dev: ## Run the app with Docker
	docker-compose run --service-ports web
