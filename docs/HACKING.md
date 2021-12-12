# Development guide

_These instructions are for hacking on Bonfire. If you wish to deploy in production, please refer to our [Deployment Guide](./DEPLOY.md)!_

Hello, potential contributor! :-)

This is a work in progress guide to getting up and running as a developer. Please ask questions in the issue tracker if something is not clear.

Happy hacking!

## Getting set up

There are three main options depending on your needs and preferences.

Either way, you need to first clone this repository and change into the directory and then do some configuration:

```sh
$ git clone https://github.com/bonfire-networks/bonfire-app.git bonfire
$ cd bonfire
```

### Configuration

- The first thing to do is choosing what flavour of Bonfire you want to hack on (the default is `classic`), as each flavour has its own config.

For example if you want to run the `coordination` flavour:

`export FLAVOUR=coordination`

- Once you've picked a flavour, run this command to initialise some default config (.env files which won't be checked into git):

`make pre-config`

- Edit the config (especially the secrets) for the current flavour in these files:
  - `config/dev/secrets.env`
  - `config/dev/public.env`

### Option A - the entry way (fully managed via docker-compose, recommended when you're first exploring)

- Dependencies:

  - `make`
  - Recent versions of Docker & [docker-compose](https://docs.docker.com/compose/install/)

- Make sure you've edited your .env files (see above) before getting started and proceed to Hello world!

### Option B - the easy way (with docker-managed database & search index, recommended for active development)

- Dependencies:

  - `make`
  - Recent versions of [Elixir](https://elixir-lang.org/install.html) (1.12+) and OTP/erlang (24+)
  - Recent versions of [Rust](https://www.rust-lang.org/tools/install) and Cargo
  - [pnpm](https://pnpm.io)
  - Recent versions of Docker & [docker-compose](https://docs.docker.com/compose/install/)

- Set an environment variable to indicate your choice: `export WITH_DOCKER=partial`

- Make sure you've edited your .env files (see above) before getting started and proceed to Hello world!

### Option C - the bare metal (if you don't use docker)

- Dependencies:

  - `make`
  - Recent versions of [Elixir](https://elixir-lang.org/install.html) (1.12+) and OTP/erlang (24+)
  - Recent versions of [Rust](https://www.rust-lang.org/tools/install) and Cargo
  - [pnpm](https://pnpm.io)
  - Postgres 12+ (or rather [Postgis](https://postgis.net/install/) if using the bonfire_geolocate extension)
  - [Meili Search](https://docs.meilisearch.com/learn/getting_started/installation.html) (optional)

- You will need to set the relevant environment variables in the .env files (see above) to match your local install of Postgres.

- If you want search capabilities, you'll also need to setup a Meili server and set the relevant env variables as well.

- Set an environment variable to indicate your choice: `export WITH_DOCKER=no` and proceed to Hello world!

### Option D - the experimental one (dev environment with Nix)

- run a recent version of Nix or NixOS: https://nixos.wiki
- enable Flakes: https://nixos.wiki/wiki/Flakes#Installing_flakes
- add `sandbox = false` in your nix.conf

If you use direnv, just cd in the directory and you will have all the dependencies.
If you just have nix, running `nix shell .` (inside the repository) will set you up with a shell.

You will need to create and init the db directory (keeping all your Postgres data inside this directory):
- create the db directory `initdb ./db`
- create the postgres user `createuser postgres -ds`
- create the db `createdb bonfire_dev`
- start the postgres instance `pg_ctl -l "$PGDATA/server.log" start`
- `mix deps.get` to get elixir dependencies
- `pushd assets && npm install && popd` to get the frontend dependencies
- `mix ecto.migrate` to compile & get an up to date database
- `iex -S mix phx.server` to start the server
- check out the app on `localhost:4000` in your browser

## Hello world!

- From a fresh checkout of this repository, this command will fetch the app's dependencies and setup the database (the same commands apply for all three options above):

```
make setup
```

- You should then be able to run the app with:

```
make dev
```

- See the `make` commands below for more things you may want to do.

## Onboarding

By default, the back-end listens on port 4000 (TCP), so you can access it on http://localhost:4000/

If you haven't set up transactional emails, while in development, you will see a signup confirmation path appear in the iex console.

Note that the first account to be registered is automatically an instance admin.

## Documentation

The code is somewhat documented inline. You can generate HTML docs (using `Exdoc`) by running `mix docs`.

## Additional information

- messctl is a little utility for programmatically updating the .deps files from which the final elixir dependencies list is compiled by the mess script. The only use of it is in the dep-\* tasks of the Makefile. It is used by some of the project developers and the build does not rely on it.

- `./forks/` is used to hack on local copies of dependencies. You can clone a dependency from its git repo (like a bonfire extension) and use the local version during development, eg: `make dep.clone.local dep=bonfire_me repo=https://github.com/bonfire-networks/bonfire_me`

- You can migrate the DB when the app is running (useful in a release): `Bonfire.Repo.ReleaseTasks.migrate`

### Usage under Windows (MSYS or CYGWIN)

If you plan on using the `Makefile` (its rather handy), you must have symlinks enabled.
You must enable developer mode, and set `core.symlink = true`, [see link.](https://stackoverflow.com/a/59761201)

## Make commands

Run `make` followed by any of these commands when appropriate rather than directly using the equivalent commands like `mix`, `docker`, `docker-compose`, etc. For example, `make setup` will get you started, and `make dev` will run the app.

You can first set an env variable to control which mode these commands will assume you're using. Here are your options:

- `WITH_DOCKER=total` : use docker for everything (default)
- `WITH_DOCKER=partial` : use docker for services like the DB
- `WITH_DOCKER=easy` : use docker for services like the DB & compiled utilities like messctl
- `WITH_DOCKER=no` : please no

```
make help                           Makefile commands help **(run this to get more up-to-date commands and help information than available in this document)**
make mix~help                       Help info for elixir's mix commands
make env.exports                    Display the vars from dotenv files that you need to load in your environment

make setup                          First run - prepare environment and dependencies
make dev                            Run the app in development
make dev.bg                         Run the app in dev mode, as a background service
make db.reset                       Reset the DB (caution: this means DATA LOSS)
make db.rollback                    Rollback previous DB migration (caution: this means DATA LOSS)
make db.rollback.all                Rollback ALL DB migrations (caution: this means DATA LOSS)
make update                         Update the app and all dependencies/extensions/forks, and run migrations

make update.app                     Update the app and Bonfire extensions in ./deps
make update.deps.bonfire            Update to the latest Bonfire extensions in ./deps
make update.deps.all                Update evey single dependency (use with caution)
make update.dep~%                   Update a specify dep (eg. `make update.dep~pointers`)
make update.forks                   Pull the latest commits from all ./forks

make deps.get                       Fetch locked version of non-forked deps
make dep.clone.local                Clone a git dep and use the local version, eg: `make dep.clone.local dep=bonfire_me repo=https://github.com/bonfire-networks/bonfire_me`
make deps.clone.local.all           Clone all bonfire deps / extensions
make dep.go.local~%                 Switch to using a local path, eg: make dep.go.local~pointers
make dep.go.local.path              Switch to using a local path, specifying the path, eg: make dep.go.local dep=pointers path=./libs/pointers
make dep.go.git                     Switch to using a git repo, eg: make dep.go.git dep=pointers repo=https://github.com/bonfire-networks/pointers (specifying the repo is optional if previously specified)
make dep.go.hex                     Switch to using a library from hex.pm, eg: make dep.go.hex dep=pointers version="~> 0.2" (specifying the version is optional if previously specified)
make dep.hex~%                      add/enable/disable/delete a hex dep with messctl command, eg: `make dep.hex.enable dep=pointers version="~> 0.2"
make dep.git~%                      add/enable/disable/delete a git dep with messctl command, eg: `make dep.hex.enable dep=pointers repo=https://github.com/bonfire-networks/pointers#main
make dep.local~%                    add/enable/disable/delete a local dep with messctl command, eg: `make dep.hex.enable dep=pointers path=./libs/pointers
make messctl~%                      Utility to manage the deps in deps.hex, deps.git, and deps.path (eg. `make messctl~help`)

make contrib.forks                  Push all changes to the app and extensions in ./forks
make contrib.release                Push all changes to the app and extensions in ./forks, increment the app version number, and push a new version/release
make contrib.app.up                 Update ./deps and push all changes to the app
make contrib.app.release            Update ./deps, increment the app version number and push
make git.forks.add                  Run the git add command on each fork
make git.forks~%                    Run a git command on each fork (eg. `make git.forks~pull` pulls the latest version of all local deps from its git remote

make test                           Run tests. You can also run only specific tests, eg: `make test only=forks/bonfire_social/test`
make test.stale                     Run only stale tests
make test.remote                    Run tests (ignoring changes in local forks)
make test.watch                     Run stale tests, and wait for changes to any module's code, and re-run affected tests
make test.db.reset                  Create or reset the test DB

make rel.build                      Build the Docker image using previous cache
make rel.tag.latest                 Add latest tag to last build
make rel.push                       Add latest tag to last build and push to Docker Hub
make rel.run                        Run the app in Docker & starts a new `iex` console
make rel.run.bg                     Run the app in Docker, and keep running in the background
make rel.stop                       Run the app in Docker, and keep running in the background
make rel.shell                      Runs a simple shell inside of the container, useful to explore the image

make services                       Start background docker services (eg. db and search backends). This is automatically done for you if using Docker.
make build                          Build the docker image
make cmd~%                          Run a specific command in the container, eg: `make cmd-messclt` or `make cmd~time` or `make cmd~echo args=hello`
make shell                          Open the shell of the Docker web container, in dev mode
make mix~%                          Run a specific mix command, eg: `make mix~deps.get` or `make mix~deps.update args=pointers`
make mix.remote~%                   Run a specific mix command, while ignoring any deps cloned into ./forks, eg: `make mix~deps.get` or `make mix~deps.update args=pointers`
make deps.git.fix                   Run a git command on each dep, to ignore chmod changes
make git.merge~%                    Draft-merge another branch, eg `make git-merge-with-valueflows-api` to merge branch `with-valueflows-api` into the current one
make git.conflicts                  Find any git conflicts in ./forks
```

## Troubleshooting

### EACCES Permissions Error

If you get a permissions error when following any of the steps, run the following command and it should be fixed:

```shell
cd ~/bonfire && sudo chown -R yourusername:yourusername .
```

### Unable to access Postgres database

If you are getting any `:nxdomain` errors, check if you have any firewalls that may be blocking the port on your system.

For example, if you are running UFW (a lot of Linux distros do), run the following command to allow access to port 4000:

```shell
sudo ufw allow 4000
```

### (Mix) Package fetch failed

Example:

```
** (Mix) Package fetch failed and no cached copy available (https://repo.hex.pm/tarballs/distillery-2.0.12.tar)
```

In this case, distillery (as an example of a dependency) made a new release and retired the old release from hex. The new version (`2.0.14`) is quite close to the version we were depending on (`2.0.12`), so we chose to upgrade:

```shell
mix deps.update distillery
```

This respects the version bounds in `mix.exs` (`~> 2.0`), so increment that if required.

### `(DBConnection.ConnectionError) tcp recv: closed`

Example:

```
** (DBConnection.ConnectionError) tcp recv: closed (the connection was closed by the pool, possibly due to a timeout or because the pool has been terminated)
```

In this case, the seeds were unable to complete because a query took too long to execute on your machine. You can configure the timeout to be larger in the `dev` environment:

1. Open `config/dev.exs` in your editor.
2. Find the database configuration (search for `Bonfire.Repo`).
3. Add `timeout: 60_000` to the list of options:

```
config :bonfire, Bonfire.Repo,
  timeout: 60_000,
  [...]
```
