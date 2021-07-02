# Backend Configuration and Deployment

# WARNING: Bonfire is still under heavy development and is not ready to be deployed or used other than for development and testing purposes. 

_These instructions are for setting up Bonfire in production. If you want to run the backend in development, please refer to our [Developer Guide](./HACKING.md)!_

---

## Step 0 - Configure your database

You must provide a postgresql database for data storage. We require postgres 12 or above (or Postgis).

If you are running in a restricted environment such as Amazon RDS, you will need to execute some sql against the database:

```
CREATE EXTENSION IF NOT EXISTS citext;
```

## Step 1 - Configure the backend

The app needs some environment variables to be configured in order to work.

In the `flavours/${FLAVOUR}/config/` directory of the codebase, there are following default config files:

- `config.exs`: default base configuration, which itself loads many other config files, such as one for each installed Bonfire extension.
- `dev.exs`: default extra configuration for `MIX_ENV=dev`
- `prod.exs`: default extra configuration for `MIX_ENV=prod`
- `runtime.exs`: extra configuration which is loaded at runtime (vs the others which are only loaded once at compile time, i.e. when you build a release)

You should NOT have to modify the files above. Instead, overload any settings from the above files using env variables (a list of which can be found in the file `${FLAVOUR}/config/prod/public.env` and `flavours/${FLAVOUR}/config/prod/secrets.env` in this same repository, both in the `main` and `release` branches).

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

2. Clone the `release` branch of repository and change into the directory:

```sh
$ git clone --branch release https://github.com/bonfire-networks/bonfire-app.git bonfire
$ cd bonfire
```

3. The first thing to do is choosing what flavour of Bonfire you want to deploy (the default is `classic`), as each flavour has its own Docker image and config. 

For example if you want to run the `coordination` flavour:

`export FLAVOUR=coordination` and edit the `image` entry in `docker-compose.yml` to reflect the corresponding image on Docker Hub.

4. Once you've picked a flavour, run this command to initialise some default config (.env files which won't be checked into git):

`make pre-config`

5. Edit the config (especially the secrets) for the current flavour in these files:
  - `config/dev/secrets.env`
  - `config/dev/public.env`

6. Start the docker containers with docker-compose:

```sh
$ make rel.run
```

7. The backend should now be running at [http://localhost:4000/](http://localhost:4000/).

8. If that worked, start the app as a daemon next time:

```sh
$ make rel.run.bg
```

#### Docker commands

- `docker-compose pull` to update to the latest release of Bonfire and other services (Postgres & Meili)
- `docker-compose run --rm web bin/bonfire` returns all the possible commands
- `docker-compose run --rm web /bin/sh` runs a simple shell inside of the container, useful to explore the image
- `docker-compose run --rm web bin/bonfire start_iex` starts a new `iex` console
- `docker-compose run web bin/bonfire remote` runs an `iex` console when the service is already running.

There are some useful database-related release tasks under `Bonfire.Repo.ReleaseTasks.` that can be run in an `iex` console:

- `migrate` runs all up migrations
- `rollback(step)` roll back to step X
- `rollback_to(version)` roll back to a specific version
- `rollback_all` rolls back all migrations back to zero (caution: this means loosing all data)

For example:
`iex> Bonfire.Repo.ReleaseTasks.migrate` to create your database if it doesn't already exist.

#### Building a Docker image

The Dockerfile uses the [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to make the image as small as possible. It is a very common release using OTP releases. It generates the release which is later copied into the final image.

There is a `Makefile` with relevant commands:

- `make rel.build` which builds the docker image in `bonfire/bonfire:latest` and `bonfire/bonfire:$VERSION-$BUILD`
- `make rel.tag.latest` adds the "latest" tag to your last build, so that it will be used when running
- `make rel.run` which can be used to run the "latest" tagged image instead of using `docker-compose`
- `make rel.run.bg` which runs it as a background service

---

### Option B - Manual installation without Docker

#### Dependencies

- Postgres (or Postgis) version 12 or newer
- Build tools
- Elixir version 1.11.0 with OTP 23 (or newer). If your distribution only has an old version available, check [Elixir's install page](https://elixir-lang.org/install.html) or use a tool like [asdf](https://github.com/asdf-vm/asdf) (run `asdf install` in this directory).

#### B-1. Building the release

- Clone the `main` branch of this repo.

- Set your environment: `export MIX_ENV=prod && export FLAVOUR=classic`

- You will need to load the required environment variables for the release to run properly. See`flavours/$(FLAVOUR)/config/runtime.exs`](config/runtime.exs) and `flavours/$(FLAVOUR)/config/prod/*.env` for all env variables which you can set. 

- Make sure you have erlang and elixir installed (check `Dockerfile` for what version we're currently using)

- From here on out, you may want to consider what your `MIX_ENV` is set to. For production, ensure that you either export `MIX_ENV=prod` or use it for each command. Continuing, we are assuming `MIX_ENV=prod`.

- Run `mix deps.get --only prod` to install elixir dependencies.

- Prepare assets with `mix js.deps.get`, `mix js.release` and `mix phx.digest`

- Run `mix release` to create an elixir release. This will create an executable in your `_build/prod/rel/bonfire` directory. We will be using the `bin/bonfire` executable from here on.

#### B-2. Running the release

- `cd _build/prod/rel/bonfire/`

- Create a database and run the migrations with `bin/bonfire eval 'Bonfire.Repo.ReleaseTasks.migrate()'`.
- If you’re using RDS or some other locked down DB, you may need to run `CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;` on your database with elevated privileges.

* You can check if your instance is configured correctly by running it with `bin/bonfire start`

* To run the instance as a daemon, use `bin/bonfire start daemon`.

#### B-3. Adding HTTPS

The common and convenient way for adding HTTPS is by using Nginx or Caddyserver as a reverse proxy.

Caddyserver and other servers can handle generating and setting up HTTPS certificates automatically, but if you need TLS/SSL certificates for nginx, you can look get some for free with [letsencrypt](https://letsencrypt.org/). The simplest way to obtain and install a certificate is to use [Certbot.](https://certbot.eff.org). Depending on your specific setup, certbot may be able to get a certificate and configure your web server automatically.

---

### Option C with nixos

this repo is a flake and includes a nixos module.
Here are the detailed steps to deploy it.

- add it as an input to your system flake.
- add an overlay to make the package available
- add the required configuration in your system

Your flake.nix file would look like the following. Remember to replace myHostName with your actual hostname or however your deployed system is called.

```nix
{
  inputs.bonfire.url = "github:happysalada/bonfire-app/main";
  outputs = { self, nixpkgs, bonfire }: {
    overlay = final: prev: with final;{
      # a package named bonfire already exists on nixpkgs so we put it under a different name
      elixirBonfire = bonfire.defaultPackage.x86_64-linux;
    };
    nixosConfigurations.myHostName = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [ agenix.defaultPackage.x86_64-linux ];
          nixpkgs.overlays = [ self.overlay ];
        }
        ./myHostName.nix
        bonfire.nixosModules.bonfire
      ];
    };
  };
}
```

then in myHostName.nix would look like the following

TODO: add the caddy config

```nix
{ config, lib, pkgs, ... }:

{
  services.bonfire = {
    # you will need to expose bonfire with a reverse proxy, for example caddy
    port = 4000;
    package = pkgs.elixirBonfire;
    dbName = "bonfire";
    # the environment should contain a minimum of
    #   SECRET_KEY_BASE
    #   SIGNING_SALT
    #   ENCRYPTION_SALT
    #   RELEASE_COOKIE
    # have a look into nix/module.nix for more details
    # the way to deploy secrets is beyond this readme, but I would recommend agenix
    environmentFile = "/run/secrets/bonfireEnv";
    dbSocketDir = "/var/run/postgresql";
  };

  # this is uniquely for database backup purposes
  # replace myBackupUserName with the user name that will do the backups
  # if you want to do backups differently, feel free to remove this part of the config
  services.postgresql = {
    ensureDatabases = [ "bonfire" ];
    ensureUsers = [{
      name = "myBackupUserName";
      ensurePermissions = { "DATABASE bonfire" = "ALL PRIVILEGES"; };
    }];
  };
}
```

## Step 3 - Run

By default, the backend listens on port 4000 (TCP), so you can access it on http://localhost:4000/ (if you are on the same machine). In case of an error it will restart automatically.

Once you've signed up, you will automatically be an instance admin if you were the first to register.
