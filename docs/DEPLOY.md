# Hosting guide

A short guide to running Bonfire in a production environment and setting up a digital space connected to the fediverse.

> #### Warning {: .warning}
>
> Bonfire is currently beta software. While it's fun to play with it, we would not recommend running any production instances yet (meaning not using it for your primary fediverse identity) because it's not quite ready for that today. 


_These instructions are for setting up Bonfire in production. If you want to run the backend in development, please refer to our [Installation guide](./hacking) instead._


## Security Warning

We recommend only granting an account to people you trust to minimise the attack surface. Accordingly, Bonfire ships with public registration disabled. The admin panel has an `invite` facility. 

---

## Step - 0 - Decide how you want to deploy and manage the app


<!-- tabs-open -->

### Co-op Cloud

Install using [Co-op Cloud](https://coopcloud.tech) (recommended) which is an alternative to corporate cloud services built by tech co-ops, and provides handy tools for setting up and managing many self-hosted free software tools using ready-to-use "recipes". Very useful if you'd like to host Bonfire alongside other open and/or federated projects. 

### Docker

Install using Docker containers 
  * Option B1 - Using pre-built Docker images (easy mode)
  * Option B2 - Building your own Docker image (if you want to make code changes or add your own extensions)


### Manual 
Install without Docker

<!-- tabs-close -->

## Step 1 - Download and configure the app

### Option A - Install using Co-op Cloud (recommended)
1. Install [Abra](https://docs.coopcloud.tech/abra/) on your machine
2. [Set up a server with co-op cloud](https://docs.coopcloud.tech/operators/) 
3. Use the [Bonfire recipe](https://recipes.coopcloud.tech/bonfire) and follow the instructions there. 
4. [Done!](#step-4-run)

### Options B and C

1. Install dependencies. 
You may need to install [just](https://github.com/casey/just#packages), and other requirements such as Docker (check the exact list of requirements based on the option you choose in step 2.)

2. Clone this repository and change into the directory:

```sh
git clone --depth 1 https://github.com/bonfire-networks/bonfire-app.git bonfire && cd bonfire
```

3. Specify what flavour you want to run in production:

The first thing to do is choose what flavour of Bonfire (eg. classic, community, or cooperation) you want to deploy, as each flavour uses different Docker images and set of configs. For example if you want to run the `classic` flavour:

- `export MIX_ENV=prod FLAVOUR=classic` 

You may also want to put this in the appropriate place in your system so your choice of flavour is remembered for next time (eg. `~/.bashrc` or `~/.zshrc`)

If you're not planning on using Docker, you'll also need:

- `export WITH_DOCKER=no`

## Step 2- Prepare the config

* **Option A**: if deploying with co-op cloud, edit the env file at `~/.abra/servers/your_server/your_app.env` instead.

* **Option B and C**: 
- Run `just config` to initialise some default config and then edit the config in the `./.env` file.

### Config keys you should pay special attention to:
The app needs these environment variables to be configured in order to work.

- `FLAVOUR` should reflect your chosen flavour
- `HOSTNAME` (your domain name, eg: `bonfire.example.com`)
- `PUBLIC_PORT` (usually 443)
- `MAIL_DOMAIN` and `MAIL_KEY` and related keys to configure transactional email, for example set `MAIL_BACKEND=mailgun` and sign up at [Mailgun](https://www.mailgun.com/) and then configure the domain name and key (you may also need to set `MAIL_BASE_URI` if your domain is not setup in EU, as the default `MAIL_BASE_URI` is set as `https://api.eu.mailgun.net/v3`). 
- SMTP is supported as well, through the following env vars 
```
MAIL_SERVER (smtp domain of the mail server)
MAIL_DOMAIN (the bit after the @ in your email)
MAIL_USER
MAIL_PASSWORD
MAIL_FROM
MAIL_PORT (optional)
MAIL_SSL (optional)
```
- `UPLOADS_S3_BUCKET` and the related API key and secret for uploads. WARNING: If you want to store uploads in an object storage rather than directly on your server (which you probably want, to not run out of space), you need to configure that up front, otherwise URLs will break if you change it later. See `config/runtime.exs` for extra variables to set if you're not using the default service and region (which is [Scaleway](https://www.scaleway.com/en/object-storage/) Paris).

### Secret keys for which you should put random secrets. 
You can run `just secrets` to generate some for you.

- `SECRET_KEY_BASE`
- `SIGNING_SALT`
- `ENCRYPTION_SALT`
- `POSTGRES_PASSWORD`
- `MEILI_MASTER_KEY` 

### Further information on config

In the `./config/` (which is a symbolic link to the config of the flavour you choose to run) directory of the codebase, there are following config files:

- `config.exs`: default base configuration, which itself loads many other config files, such as one for each installed Bonfire extension.
- `prod.exs`: default extra configuration for `MIX_ENV=prod`
- `runtime.exs`: extra configuration which is loaded at runtime (vs the others which are only loaded once at compile time, i.e. when you build a release)
- `bonfire_*.exs`: configs specific to different extensions, which are automatically imported by `config.exs`

You should *not* have to modify the files above. Instead, overload any settings from the above files using env variables or in `./.env`. If any settings in the `.exs` config files are not available in env or in the instance settings UI, please open an issue or PR.


## Step 3 - Install

### Option A - Install using Co-op Cloud (recommended)
Follow the instructions in the coop-cloud recipe readme.

### Option B - Install using Docker containers (easy mode)

The easiest way to launch the docker image is using the just commands.
The `docker-compose.release.yml` uses `config/prod/.env` to launch a container with the necessary environment variables along with its dependencies, currently that means an extra postgres container, along with a reverse proxy (Caddy server, which you may want to replace with nginx or whatever you prefer).

Make sure you have [Docker](https://www.docker.com/), with the [compose](https://docs.docker.com/compose/install/#install-compose) plugin, and [just](https://github.com/casey/just#packages) installed:

```sh
$ docker version
Docker Engine - Community - 23.0.1

$ docker compose version
Docker Compose version v2.16.0

$ just --version
just 1.13.0
...
```

Now that your tooling is set up, you have the choice of using pre-built images or building your own. For example if your flavour does not have a prebuilt image on Docker Hub, or if you want to customise any of the extensions, you can build one yourself - see option B2 below. 

#### Option B1 - Using pre-built Docker images (recommended to start with)

- The `image` entry in `docker-compose.release.yml` will by default use the image on Docker Hub which corresponds to your chosen flavour (see step 1 above for choosing your flavour).

You can see the images available per flavour, version (we currently recommend using the `latest` tag), and architecture at https://hub.docker.com/r/bonfirenetworks/bonfire/tags 

- Start the docker containers with docker-compose:

```
just rel-run
```

Run this at the prompt: 

`bin/bonfire remote` to enter Elixir's iex environment
`Bonfire.Common.Repo.migrate` to initialise your database

The backend should now be running at [http://localhost:4000/](http://localhost:4000/).

- If that worked, start the app as a daemon next time:

```
just rel-run-bg
```

(Alternatively, `just rel-run-bg db` if you want to run the backend + db but not the web proxy, or `just rel-run-bg db search` if you want to run the full-text search index.)

#### Docker-related handy commands

- `just update` to update to the latest release of Bonfire 
- `just rel-run`                        Run the app in Docker, in the foreground
- `just rel-run-bg`                     Run the app in Docker, and keep running in the background
- `just rel-stop`                       Stop the running release
- `just rel-shell`                      Runs a simple shell inside of the container, useful to explore the image 

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

There are some useful database-related release tasks under `EctoSparkles.Migrator.` that can be run in an `iex` console (which you get to with `just rel.shell` followed by `bin/bonfire remote`, assuming the app is already running):

- `migrate` runs all up migrations
- `rollback(step)` roll back to step X
- `rollback_to(version)` roll back to a specific version
- `rollback_all` rolls back all migrations back to zero (caution: this means losing all data)

You can also directly call some functions in the code from the command line, for example:
- to migrate: `docker exec bonfire_web bin/bonfire rpc 'Bonfire.Common.Repo.migrate'`
- to just yourself an admin: `docker exec bonfire_web bin/bonfire rpc 'Bonfire.Me.Users.make_admin("my_username")'`

#### Option B2 - Building your own Docker image

`Dockerfile.release` uses the [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to just the image as small as possible. It generates the OTP release which is later copied into the final image packaged in an Alpine linux container.

There is a `justfile` with relevant commands (make sure set the `MIX_ENV=prod` env variable):

- `just rel-build-release` which builds the docker image of the latest release
- `just rel-build` which builds the docker image, including local changes to any cloned extensions in `./extensions/` 
- `just rel-tag` adds the "latest" tag to your last build, so that it will be used when running

Once you've built and tagged your image, you may need to update the `image` name in `docker-compose.release.release.yml` to match (either your local image name if running on the same machine you used for the build, or a remote image on Docker Hub if you pushed it) and then follow the same steps as for option A1.

For production, we recommend to set up a CI workflow to automate this, for an example you can look at the one [we currently use](../github/workflows/release.yaml).

---

### Option C - Manual installation (without Docker)

#### Dependencies

- Postgres (or Postgis) version 12 or newer
- [just](https://github.com/casey/just#packages)
- Elixir version 1.15+ with OTP 25+. If your distribution only has an old version available, check [Elixir's install page](https://elixir-lang.org/install.html) or use a tool like [mise](https://github.com/jdx/mise) (run `mise install` in this directory) or asdf.

1. Building the release

- Make sure you have erlang and elixir installed (check `Dockerfile` for what version we're currently using)

- `export WITH_DOCKER=no` OR add `WITH_DOCKER=no` to the end of `.env` and source it with `source .env`

- Run `just rel-build` to create an elixir release. This will create an executable in your `_build/prod/rel/bonfire` directory. Note that you will need `just` to pass in the `.env` file to the executable, like so: `just cmd _build/prod/rel/bonfire/bin/bonfire <bonfire command>`. Alternatively, this file can be sourced by `source .env` instead. We will be using the `bin/bonfire` executable as called from `just` from here on. 

2. Running the release

- Create a database, and a user, fill out the `.env` with your credentials and secrets

- You will need to use `just` in order to pass the `.env` file to the executable. This can be accomplished by running `just cmd _build/prod/rel/bonfire/bin/bonfire <bonfire command>`. Just works from the root directory of the `justfile`, not your current directory.

- If you’re using RDS or some other locked down DB, you may need to run `CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;` on your database with elevated privileges.

- You can check if your instance is configured correctly and get to the iex console by running `bin/bonfire start`

- The migrations should automatically run on first boot, but if you run into troubles the migration command is: `Bonfire.Common.Repo.migrate()` in the iex console. 

- To run the instance as a daemon, use `bin/bonfire start daemon`.

---

### Option D - with Nix

This repo is a Flake and includes a Nix module.

Here are the detailed steps to deploy it:

- run a recent version of Nix or NixOS: https://nixos.wiki
- enable Flakes: https://nixos.wiki/wiki/Flakes#Installing_flakes
- add `sandbox = false` in your nix.conf
- fetch and build the app and dependencies: `nix run github:bonfire-networks/bonfire-app start_iex`
- add it as an input to your system flake.
- add an overlay to just the package available
- add the required configuration in your system

Your `flake.nix` file would look like the following. Remember to replace `myHostName` with your actual hostname or however your deployed system is called.

```nix
{
  inputs.bonfire.url = "github:bonfire-networks/bonfire-app/main";
  outputs = { self, nixpkgs, bonfire }: {
    overlay = final: prev: with final;{
      # a package named bonfire already exists on nixpkgs so we put it under a different name
      elixirBonfire = bonfire.packages.x86_64-linux.default;
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
	
	# this is specifically for a reverse proxy, which is primarily used for SSL certs
	services.ngnix = {
		enable = true;
		forceSSL = true;
		enableACME = true;
		virtualHosts."myHostName".locations.proxyPass = "http://localhost:4000";
	};
	
	# You will need to accept ACME's terms and conditions if you haven't elsewhere in your configuration
	security.acme.defaults.email = "you@myHostName.com";
	security.acme.acceptTerms = true;

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


## Step 4 - Run

By default, the backend listens on port 4000 (TCP), so you can access it on http://localhost:4000/ (if you are on the same machine). In case of an error it will restart automatically.

Once you've signed up, you will automatically be an instance admin if you were the first to register.

> NOTE: If you are running in a restricted environment such as Amazon RDS, you will need to execute some sql against the database before migrations can run: `CREATE EXTENSION IF NOT EXISTS citext;`


#### Step 5 - Adding HTTPS

The common and convenient way for adding HTTPS is by using a reverse proxy like Nginx or Caddyserver (the latter of which is bundled as part of the docker compose setup).

Caddyserver and other servers can handle generating and setting up HTTPS certificates automatically, but if you need TLS/SSL certificates for nginx, you can look get some for free with [letsencrypt](https://letsencrypt.org/). The simplest way to obtain and install a certificate is to use [Certbot.](https://certbot.eff.org). Depending on your specific setup, certbot may be able to get a certificate and configure your web server automatically.

If you've built from source, you should point the nginx root directory to be `_build/prod/rel/bonfire/lib/bonfire-[current-version]/priv/static`


## Admin tools

- LiveDashboard for viewing real-time metrics and logs at `/admin/system/`
- Oban logs for viewing queued jobs (e.g. for processing federated activities) `/admin/system/oban_queues`
- LiveAdmin for browsing data in the database at `/admin/system/data`
- Orion for dynamic distributed performance profiling at `/admin/system/orion`
- Web Observer as an alternative way to view metrics at `/admin/system/wobserver`


## Troubleshooting

Some common issues that may arise during deployment and our suggestions for resolving them.

#### WebSocket connections not establishing behind a reverse proxy

If you are running Bonfire behind your own reverse proxy (e.g. nginx), you might experience issues with WebSocket connections not establishing. WebSocket connections require specific configuration to work, in nginx the following configuration is necessary for websockets to work:

```
location /live/websocket {
    proxy_pass http://127.0.0.1:4000;
    
    # these configurations are necessary to proxy WebSocket requests
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```
