# Backend Configuration and Deployment

# WARNING: Bonfire is still under heavy development and is not ready to be deployed or used other than for development and testing purposes. 

_These instructions are for setting up Bonfire in production. If you want to run the backend in development, please refer to our [Developer Guide](./HACKING.md)!_

---

## Step 0 - Configure your database

You must provide a postgresql database for data storage. We require postgres 9.4 or above.

If you are running in a restricted environment such as Amazon RDS, you will need to execute some sql against the database:

```
CREATE EXTENSION IF NOT EXISTS citext;
```

## Step 1 - Configure the backend

The app needs some environment variables to be configured in order to work (a list of which can be found in the file `config/docker.env` in this same repository).

In the `${FLAVOUR}/config/` directory, there are following default config files:

- `config.exs`: default base configuration, which itself loads many other config files, such as one for each installed Bonfire extension.
- `dev.exs`: default extra configuration for `MIX_ENV=dev`
- `prod.exs`: default extra configuration for `MIX_ENV=prod`
- `runtime.exs`: extra configuration which is loaded at runtime (vs the others which are only loaded once at compile time, i.e. when you build a release)

You should NOT have to modify the files above. Instead, overload any settings from the above files using env variables (a list of which can be found in the file `${FLAVOUR}/config/prod/public.env` and `${FLAVOUR}/config/prod/secrets.env`  in this same repository).

`MAIL_DOMAIN` and `MAIL_KEY` are needed to configure transactional email, you can for example sign up at [Mailgun](https://www.mailgun.com/) and then configure the domain name and key.

---

## Step 2 - Install

---

### Option A - Install using Docker containers (recommended)

The easiest way to launch the docker image is using the make commands.
The `docker-compose.release.yml` uses `config/prod/public.env` and `config/prod/secrets.env` to launch a container with the necessary environment variables along with its dependencies, currently that means an extra postgres container. You may want to add a webserver / reverse proxy yourself.

#### Install with docker-compose

1. Make sure you have [Docker](https://www.docker.com/), a recent [docker-compose](https://docs.docker.com/compose/install/#install-compose) (which supports v3 configs), and [make](https://www.gnu.org/software/make/) installed:

```sh
$ docker version
Docker version 18.09.1-ce

$ docker-compose -v
docker-compose version 1.23.2

$ make --version
GNU Make 4.2.1
...
```

2. Clone this repository and change into the directory:

```sh
$ git clone git@gitlab.com:Bonfire/Server.git bonfire-backend
$ cd bonfire-backend
```

3. Build the docker image.

```
$ make rel-build

$ make rel-tag-latest
```

4. Start the docker containers with docker-compose:

```sh
$ make rel-run
```

5. The backend should now be running at [http://localhost:4000/](http://localhost:4000/).

6. If that worked, start the app as a daemon next time:

```sh
$ make rel-run-bg
```

#### Docker commands

- `docker-compose run --rm backend bin/bonfire` returns all the possible commands
- `docker-compose run --rm backend /bin/sh` runs a simple shell inside of the container, useful to explore the image
- `docker-compose run --rm backend bin/bonfire start_iex` starts a new `iex` console
- `docker-compose run backend bin/bonfire remote` runs an `iex` console when the service is already running.

There are some useful database-related release tasks under `Bonfire.Repo.ReleaseTasks.` that can be run in an `iex` console:

- `migrate` runs all up migrations
- `rollback(step)` roll back to step X
- `rollback_to(version)` roll back to a specific version
- `rollback_all` rolls back all migrations back to zero (caution: this means loosing all data)

For example:
`iex> Bonfire.Repo.ReleaseTasks.migrate` to create your database if it doesn't already exist.

#### Building a Docker image

The Dockerfile uses the [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to make the image as small as possible. It is a very common release using OTP releases. It generates the release which is later copied into the final image.

There is a `Makefile` with two relavant commands:

- `make rel-build` which builds the docker image in `bonfire/bonfire:latest` and `bonfire/bonfire:$VERSION-$BUILD`
- `make rel-run` which can be used to run the docker built docker image instead of using `docker-compose`

---

### Option B - Manual installation without Docker

#### Dependencies

- Postgres version 9.6 or newer
- Build tools
- Elixir version 1.9.0 with OTP 22 (or possibly newer). If your distribution only has an old version available, check [Elixir's install page](https://elixir-lang.org/install.html) or use a tool like [asdf](https://github.com/asdf-vm/asdf) (run `asdf install` in this directory).

#### Quickstart

The quick way to get started with building a release, assuming that elixir and erlang are already installed.

```bash
$ export MIX_ENV=prod
$ mix deps.get
$ mix release
# TODO: load required env variables
$ _build/prod/rel/bonfire/bin/bonfire eval 'Bonfire.Repo.ReleaseTasks.migrate()'
# DB migrated
$ _build/prod/rel/bonfire/bin/bonfire start
# App started in foreground
```

See the section on [Runtime Configuration](#runtime-configuration) for information on exporting environment variables.

#### B-1. Building the release

- Clone this repo.
- Make sure you have erlang and elixir installed (check `Dockerfile` for what version we're currently using)
- Run `mix deps.get` to install elixir dependencies.
- From here on out, you may want to consider what your `MIX_ENV` is set to. For production, ensure that you either export `MIX_ENV=prod` or use it for each command. Continuing, we are assuming `MIX_ENV=prod`.
- Run `mix release` to create an elixir release. This will create an executable in your `_build/prod/rel/bonfire` directory. We will be using the `bin/bonfire` executable from here on.

#### B-2. Running the release

- Export all required environment variables. See [Runtime Configuration](#runtime-configuration) section.

- Create a database, if one is not created already with `bin/bonfire eval 'Bonfire.ReleaseTasks.create_db()'`.
- You will likely also want to run the migrations. This is done similarly with `bin/bonfire eval 'Bonfire.Repo.ReleaseTasks.migrate()'`.
- If you’re using RDS or some other locked down DB, you may need to run `CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;` on your database with elevated privileges.

* You can check if your instance is configured correctly by running it with `bonfire start`

* To run the instance as a daemon, use `bin/bonfire daemon`.

#### B-3. Adding HTTPS

The common and convenient way for adding HTTPS is by using Nginx or Caddyserver as a reverse proxy.

Caddyserver handles generating and setting up HTTPS certificates automatically, but if you need TLS/SSL certificates for nginx, you can look get some for free with [letsencrypt](https://letsencrypt.org/). The simplest way to obtain and install a certificate is to use [Certbot.](https://certbot.eff.org). Depending on your specific setup, certbot may be able to get a certificate and configure your web server automatically.

#### Runtime configuration

You will need to load the required environment variables for the release to run properly.

See [`config/releases.exs`](config/releases.exs) for all used variables. Consider also viewing there [`config/docker.env`](config/docker.env) file for some examples of values.

---

## Step 3 - Run

By default, the backend listens on port 4000 (TCP), so you can access it on http://localhost:4000/ (if you are on the same machine). In case of an error it will restart automatically.

Once you've signed up, you will automatically be an instance admin if you were the first to register.
