# Development guide

_These instructions are for hacking on Bonfire. If you wish to deploy in production, please refer to our [Deployment Guide](./DEPLOY.md)!_

Hello, potential contributor! :-)

This is a work in progress guide to getting up and running as a
developer. Please ask questions in the issue tracker if something is
not clear and we'll try to improve it.

Happy hacking!

## Status: alpha - have fun but don't run in production.

Bonfire is currently alpha software. While it's fun to play with it,
we would _absolutely not_ recommend running any production instances
yet because it's just not ready for that today.

## Download

Either way, you need to first clone this repository and change into the directory and then do some configuration:

```sh
$ git clone https://github.com/bonfire-networks/bonfire-app bonfire
$ cd bonfire
```

## Configure

### Pick a flavour

Bonfire is a flexible platform that powers a variety of social networks. The first thing you have to choose is which app (or "flavour") you want to hack on:

- `classic` ("Bonfire Social", a toot-based social network that interoperates with the fediverse)
- `cooperation` (for building cooperative communities)
- `reflow` (for community economic activities)
- `haha` (for learning new things)

Note that at the current time, the core team are focusing most of
their efforts on the classic flavour and this is where we recommend you start.

You first need to install [just](https://github.com/casey/just#packages) which is a handy tool (a `just` alternative) to run commands defined in `./justfile`.

So for example if you want to run the `classic` flavour, run:

`just config classic`

### Configure

- Then edit the config (especially the secrets) for the current flavour in `./.env`

### Option A - the entry way (fully managed via docker-compose, recommended when you're first exploring)

- Dependencies:
  - Recent versions of Docker & [docker-compose](https://docs.docker.com/compose/install/)

- Set an environment variable to indicate your choice: `export WITH_DOCKER=total`

- Make sure you've edited your .env file (see above) before getting started and proceed to Hello world!

### Option B - the easy way (with bare-metal elixir, and docker-managed tooling, database & search index, recommended for active development)

- Dependencies:
  - Recent versions of [Elixir](https://elixir-lang.org/install.html) (1.13+) and OTP/erlang (24+)
  - [yarn](https://yarnpkg.com)
  - Recent versions of Docker & [docker-compose](https://docs.docker.com/compose/install/)

- Set an environment variable to indicate your choice: `export WITH_DOCKER=easy`

- Make sure you've edited your .env file (see above) before getting started and proceed to Hello world!

### Option C - the partial way (with bare-metal elixir and tooling, and docker-managed database & search index)

- Dependencies:
  - Recent versions of [Elixir](https://elixir-lang.org/install.html) (1.13+) and OTP/erlang (24+)
  - Recent versions of [Rust](https://www.rust-lang.org/tools/install) and Cargo
  - [yarn](https://yarnpkg.com)
  - Recent versions of Docker & [docker-compose](https://docs.docker.com/compose/install/)

- Set an environment variable to indicate your choice: `export WITH_DOCKER=partial`

- Make sure you've edited your .env file (see above) before getting started and proceed to Hello world!

### Option D - the bare metal (if you don't use docker)

- Dependencies:
  - Recent versions of [Elixir](https://elixir-lang.org/install.html) (1.13+) and OTP/erlang (24+)
  - Recent versions of [Rust](https://www.rust-lang.org/tools/install) and Cargo
  - [yarn](https://yarnpkg.com)
  - Postgres 12+ (or rather [Postgis](https://postgis.net/install/) if using the bonfire_geolocate extension)
  - [Meili Search](https://docs.meilisearch.com/learn/getting_started/installation.html) (optional)

- You will need to set the relevant environment variables in the .env file (see above) to match your local install of Postgres.

- If you want search capabilities, you'll also need to setup a Meili server and set the relevant env variables as well.

- Set an environment variable to indicate your choice: `export WITH_DOCKER=no` and proceed to Hello world!

### Option E - the experimental one (dev environment with Nix)

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
- `pushd assets && yarn && popd` to get the frontend dependencies
- `mix ecto.migrate` to compile & get an up to date database
- `iex -S mix phx.server` to start the server
- check out the app on `localhost:4000` in your browser

## Hello world!

- From a fresh checkout of this repository, this command will fetch the app's dependencies and setup the database (the same commands apply for all three options above):

```
just setup
```

- You should then be able to run the app with:

```
just dev
```

- See the `just` commands below for more things you may want to do.

## Onboarding

By default, the back-end listens on port 4000 (TCP), so you can access it on http://localhost:4000/

Your first step will be to create an account to log in with. The
easiest way to do this is with our mix task:

```
$ just mix bonfire.account.new
Enter an email address: root@localhost
Enter a password:
```

Your password must be at least 10 characters long and the output could be more helpful if you don't do that. This task seems to work most reliably if you open a second terminal window with the devserver running. We're not sure why.

You should then be able to log in and create a user through the web interface.

If you would like to become an administrator, there is a mix task for that too:

```shell
just mix bonfire.user.admin.promote your_username 
```

## The Bonfire Environment

We like to think of bonfire as a comfortable way of developing software - there are a lot of
conveniences built in once you know how they all work. The gotcha is that while you don't know them, it can be a bit overwhelming. Don't worry, we've got your back.

* [Architecture](./ARCHITECTURE.md) - an overview of the stack and code structure.
- [Bonfire-flavoured Elixir](./BONFIRE-FLAVOURED-ELIXIR.md) - an introduction to the way we write Elixir.
- [Bonfire's Database: an Introduction](./DATABASE.md) - an overview of how our database is designed.
- [Boundaries](./BOUNDARIES.md) - an introduction to our access control system.

Note: these are still at the early draft stage, we expect to gradually improve documentation over time.

## Documentation

The code is somewhat documented inline. You can generate HTML docs (using `Exdoc`) by running `just docs`.

## Additional information

- messctl is a little utility for programmatically updating the .deps files from which the final elixir dependencies list is compiled by the mess script. The only use of it is in the dep-\* tasks of the Makefile. It is used by some of the project developers and the build does not rely on it.

- `./forks/` is used to hack on local copies of dependencies. You can clone a dependency from its git repo (like a bonfire extension) and use the local version during development, eg: `just dep.clone.local bonfire_me https://github.com/bonfire-networks/bonfire_me`

- You can migrate the DB when the app is running (also runs automatically on startup): `EctoSparkles.Migrator.migrate`

### Usage under Windows (WSL, MSYS or CYGWIN)

By default, the `justfile` requires symlinks, which can be enabled with the help of [this link](https://stackoverflow.com/a/59761201).

See the [pull request adding WSL support](https://github.com/bonfire-networks/bonfire-app/pull/111) for details about usage without symlinks.

## `just` commands

Run `just` followed by any of these commands when appropriate rather than directly using the equivalent commands like `mix`, `docker`, `docker-compose`, etc. For example, `just setup` will get you started, and `just dev` will run the app.

You can first set an env variable to control which mode these commands will assume you're using. Here are your options:

- `WITH_DOCKER=total` : use docker for everything (default)
- `WITH_DOCKER=partial` : use docker for services like the DB
- `WITH_DOCKER=easy` : use docker for services like the DB & compiled utilities like messctl
- `WITH_DOCKER=no` : please no

Run `just help` to see the list of possible commands and what they do.


## Troubleshooting

### EACCES Permissions Error

If you get a permissions error when following any of the steps, run the following command and it should be fixed:

```shell
cd bonfire && sudo chown -R yourusername:yourusername .
```

Note that the command should be modified so your shell is pointing to wherever you have bonfire installed. If you are already in the bonfire directory then you only need to worry about running the `chown` portion of the command.

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
