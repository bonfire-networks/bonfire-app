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

## Step 1 - Download and configure the app

1. Clone this repository and change into the directory:

```sh
$ git clone https://github.com/bonfire-networks/bonfire-app.git bonfire
$ cd bonfire
```

2. The first thing to do is choosing what flavour of Bonfire you want to deploy (the default is `classic`), as each flavour has its own Docker image and config. 

For example if you want to run the `coordination` flavour (you may want to use direnv or something similar to persist this):

`export FLAVOUR=coordination MIX_ENV=prod`

3. Once you've picked a flavour, run this command to initialise some default config (.env files which won't be checked into git):

`make pre-config`

4. Edit the config (especially the secrets) for the current flavour in these files:
- `config/prod/secrets.env`
- `config/prod/public.env`

These are the config keys you should especially pay attention to, in secrets.env:
- SECRET_KEY_BASE
- SIGNING_SALT
- ENCRYPTION_SALT
- POSTGRES_PASSWORD
- MEILI_MASTER_KEY

You can use `make secrets` to generate some secrets keys to use.

And in public.env:
- HOSTNAME
- PUBLIC_PORT

### Further information on config

The app needs some environment variables to be configured in order to work. The easy way to manage that is whit the `make` commands which take care of loading the environment for you.

In the `${FLAVOUR_PATH}/config/` (depending on which flavour you choose to run) directory of the codebase, there are following default config files:

- `config.exs`: default base configuration, which itself loads many other config files, such as one for each installed Bonfire extension.
- `dev.exs`: default extra configuration for `MIX_ENV=dev`
- `prod.exs`: default extra configuration for `MIX_ENV=prod`
- `runtime.exs`: extra configuration which is loaded at runtime (vs the others which are only loaded once at compile time, i.e. when you build a release)
- `bonfire_*.exs`: configs specific to different extensions, which are automatically imported by `config.exs`

You should *not* have to modify the files above. Instead, overload any settings from the above files using env variables (a list of which can be found in the file `${FLAVOUR_PATH}/config/templates/public.env` and `${FLAVOUR_PATH}/config/templates/secrets.env` in this same repository, both in the `main` and `release` branches). 

`MAIL_DOMAIN` and `MAIL_KEY` are needed to configure transactional email, you can for example sign up at [Mailgun](https://www.mailgun.com/) and then configure the domain name and key.

---

## Step 2 - Install

---

### Option A - Install using Docker containers (recommended)

The easiest way to launch the docker image is using the make commands.
The `docker-compose.release.yml` uses `config/prod/public.env` and `config/prod/secrets.env` to launch a container with the necessary environment variables along with its dependencies, currently that means an extra postgres container, along with a reverse proxy (Caddy server, which you may want to replace with nginx or whatever you prefer).

#### Install with docker-compose

A-1. Make sure you have [Docker](https://www.docker.com/), a recent [docker-compose](https://docs.docker.com/compose/install/#install-compose) (which supports v3 configs), and [make](https://www.gnu.org/software/make/) installed:

```sh
$ docker version
Docker version 18.09.1-ce

$ docker-compose -v
docker-compose version 1.23.2

$ make --version
GNU Make 4.2.1
...
```

A-2. Edit the `image` entry in `docker-compose.release.yml` to reflect the image on Docker Hub which corresponds to your chosen flavour. (If your flavour does not have a prebuilt image on Docker Hub you can build one yourself, see the section on Building a Docker image below, or set up a CI workflow.)

A-3. Start the docker containers with docker-compose:

```
make rel.run
```

The backend should now be running at [http://localhost:4000/](http://localhost:4000/).

A-4. If that worked, start the app as a daemon next time:

```
make rel.run.bg
```

#### Docker-related handy commands

- `docker-compose pull` to update to the latest release of Bonfire (only if using a Docker Hub image) and other services (Postgres & Meili)
- `make rel.run`                        Run the app in Docker, in the foreground
- `make rel.run.bg`                     Run the app in Docker, and keep running in the background
- `make rel.stop`                       Stop the running release
- `make rel.shell`                      Runs a simple shell inside of the container, useful to explore the image 

Once in the shell, you can run `bin/bonfire` with the following commands:
Usage: `bonfire COMMAND [ARGS]`

The known commands are:
- `start`          Starts the system
- `start_iex`      Starts the system with IEx attached
- `daemon`         Starts the system as a daemon
- `daemon_iex`     Starts the system as a daemon with IEx attached
- `eval "EXPR"`    Executes the given expression on a new, non-booted system
- `rpc "EXPR"`     Executes the given expression remotely on the running system
- `remote`         Connects to the running system via a IEx remote shell
- `restart`        Restarts the running system via a remote command
- `stop`           Stops the running system via a remote command
- `pid`            Prints the operating system PID of the running system via a remote command
- `version`        Prints the release name and version to be booted

There are some useful database-related release tasks under `Bonfire.Repo.ReleaseTasks.` that can be run in an `iex` console (which you get to with `make rel.shell` followed by `bin/bonfire remote`, assuming the app is already running):

- `migrate` runs all up migrations
- `rollback(step)` roll back to step X
- `rollback_to(version)` roll back to a specific version
- `rollback_all` rolls back all migrations back to zero (caution: this means loosing all data)

For example:
`iex> Bonfire.Repo.ReleaseTasks.migrate` to create your database if it doesn't already exist.

#### Building a Docker image

The Dockerfile uses the [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to make the image as small as possible. It is a very common release using OTP releases. It generates the release which is later copied into the final image.

There is a `Makefile` with relevant commands (make sure you set the `MIX_ENV=prod` env first):

- `make rel.build` which builds the docker image 
- `make rel.tag.latest` adds the "latest" tag to your last build, so that it will be used when running
- `make rel.push` add latest tag to last build and push to Docker Hub

---

### Option B - Manual installation without Docker

#### Dependencies

- Postgres (or Postgis) version 12 or newer
- Build tools
- Elixir version 1.11.0 with OTP 23 (or newer). If your distribution only has an old version available, check [Elixir's install page](https://elixir-lang.org/install.html) or use a tool like [asdf](https://github.com/asdf-vm/asdf) (run `asdf install` in this directory).

#### B-1. Building the release

- Make sure you have erlang and elixir installed (check `Dockerfile` for what version we're currently using)

- Run `mix deps.get --only prod` to install elixir dependencies.

- Prepare assets with `make js.deps.get`, `make assets.release` and `mix phx.digest`

- Run `mix release` to create an elixir release. This will create an executable in your `_build/prod/rel/bonfire` directory. We will be using the `bin/bonfire` executable from here on.

#### B-2. Running the release

- `cd _build/prod/rel/bonfire/`

- Create a database and run the migrations with `bin/bonfire eval 'Bonfire.Repo.ReleaseTasks.migrate()'`.
- If you’re using RDS or some other locked down DB, you may need to run `CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;` on your database with elevated privileges.

* You can check if your instance is configured correctly by running it with `bin/bonfire start`

* To run the instance as a daemon, use `bin/bonfire start daemon`.


---

### Option C with nixos

This repo is a Flake and includes a NixOS module.

Here are the detailed steps to deploy it:

- run a recent version of Nix or NixOS: https://nixos.wiki
- enable Flakes: https://nixos.wiki/wiki/Flakes#Installing_flakes
- fetch and build the app and dependencies: `nix shell github:bonfire-networks/bonfire-app --command bonfire --version`
- add it as an input to your system flake.
- add an overlay to make the package available
- add the required configuration in your system

Your `flake.nix` file would look like the following. Remember to replace `myHostName` with your actual hostname or however your deployed system is called.

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

Then your `myHostName.nix` would look like the following:

TODO: add caddy reverse proxy config

```nix
{ config, lib, pkgs, ... }:

{
  services.bonfire = {
    # you will additionally need to expose bonfire with a reverse proxy, for example caddy
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

---

#### Step 4 - Adding HTTPS

The common and convenient way for adding HTTPS is by using a reverse proxy like Nginx or Caddyserver (the latter of which is bundled as part of the docker-compose setup).

Caddyserver and other servers can handle generating and setting up HTTPS certificates automatically, but if you need TLS/SSL certificates for nginx, you can look get some for free with [letsencrypt](https://letsencrypt.org/). The simplest way to obtain and install a certificate is to use [Certbot.](https://certbot.eff.org). Depending on your specific setup, certbot may be able to get a certificate and configure your web server automatically.