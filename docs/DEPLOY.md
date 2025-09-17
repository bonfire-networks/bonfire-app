<!--
SPDX-FileCopyrightText: 2025 Bonfire Networks <https://bonfirenetworks.org/contact/>

SPDX-License-Identifier: AGPL-3.0-only
SPDX-License-Identifier: CC0-1.0
-->

# Hosting guide


A short guide to running Bonfire in a production environment and setting up a digital space connected to the fediverse.

> #### Status {: .info}
> The release candidate of Bonfire Social 1.0 is ready! Other flavours of Bonfire are currently at alpha or beta stages. 

_These instructions are for setting up Bonfire in production. If you want to run the backend in development, please refer to our [Installation guide](./HACKING.md) instead._

> **Before you begin:**  
> Make sure you have completed the [Setup Tutorial](./SETUP.md) to prepare your server, domain, mail, and DNS.  
> This guide assumes your infrastructure is ready and covers installing and configuring Bonfire itself.

> **Warning**
> By default sign ups are by invite only. You can invite people via instance settings, or open up for public registrations (just make sure you have a code of conduct and moderation team in place first). 

---

## Step 1 - Decide how you want to deploy and manage the app

<!-- tabs-open -->

### Co-op Cloud

Install using [Co-op Cloud](https://coopcloud.tech) (recommended) which is an alternative to corporate cloud services built by tech co-ops, and provides handy tools for setting up and managing many self-hosted free software tools using ready-to-use "recipes". Very useful if you'd like to host Bonfire alongside other open and/or federated projects. 

#### 1. Install Coop-Cloud on your server

Follow this [guide to setup Docker and Coop Cloud](https://docs.coopcloud.tech/operators/tutorial/) on your server.

If you have any issues connecting with SSH, here's a [guide for coop-cloud ssh issues](https://docs.coopcloud.tech/abra/trouble/#ssh-connection-issues):

> [!Tip] Protip
> Ensure .ssh/config file is set up
> ```
> Host [yourdomain.net]
>     HostName [yourdomain.net]
>     User [root]
>     IdentityFile ~/.ssh/[your_ssh_key]
> ```

#### 2. Install Abra on your computer

[Abra](https://docs.coopcloud.tech/abra/) is installed locally on your machine and acts as the remote control to Coop-Cloud, letting you manage software installations more easily from your local machine. 

[Follow the Abra installation guide](https://docs.coopcloud.tech/abra/install/).

##### 2.1. Add your server to Abra

Here's a guide for how to [add your server](https://docs.coopcloud.tech/operators/tutorial/#install-abra) to Abra. This tutorial works well until you need to install the app. When you reach the "Nextcloud" part of the guide, switch back to this guide.

- The command for adding the server is `abra server add [yourdomain.net]` or e.g. `abra server add [social.yourdomain.net]` if using a subdomain
- To see that it works, check `abra server ls` and you'll get a cute happy message

> [!Tip] Protip
> Try pinging *traefik.yourdomain.net* to see that it works:
> `ping traefik.yourdomain.net`

#### 3. Install Traefik

[Traefik](https://doc.traefik.io/traefik/) is a proxy that supports developers with publishing services. This will make it easy to ensure that your bonfire instance is up to date! 

Install by following this [recipie to install Traefik](https://recipes.coopcloud.tech/traefik).

Remember to add a valid email when configuring Traefik to generate a SSL certificate (abra app config traefik.yourdomain) - that's the only field you need to configure for traefik to work

> [!Tip] Protip 
> You can try using --chaos to tell abra to use the recipe that you have set up locally rather than pulling it from the repository if the traefik setup is stucked

#### 4. Install Bonfire

Use the [Bonfire recipe](https://recipes.coopcloud.tech/bonfire) and follow the instructions there. 

- Editing the config file:
	-  `abra app config [yourdomain.net]`
	- See [prepare the config](#preparing-the-config-in-env) for details about what to edit, for example you should add the email sending key:
```
	MAIL_BACKEND=mailgun
	MAIL_DOMAIN=[yourdomain.net]
	MAIL_KEY=[your-mailgun-sending-key]
	MAIL_FROM=[from@yourdomain.net]
```

- Deploying: 
`abra app deploy [yourdomain.net]`

- If redeploying, you can force deploy:
`abra app deploy [yourdomain.net] --force`

> **Protip**
> You can turn the `~/abra/servers/yourdomain.net` directory into a git repo and share it (privately!) with collaborators. It's also useful as a backup if you loose access to your machine or want to manager the server from a different place.

#### CoopCloud FAQs

* How to connect to the bonfire app via command line?
    `abra app run [yourinstance.net] app bin/bonfire remote`

* How to sign up with command line? 
    * `abra app run [yourinstance.net] app bin/bonfire remote` 
    * and then in the IEx console: `Bonfire.Me.make_account_only("my@email.net", "my pw")`

* How to see logs?
    * for bonfire logs: `abra app logs [yourinstance.net] app`
    * to include logs of the DB and web proxy: `abra app logs [yourinstance.net]`

* How to set up backups?
    * see this coopcloud recipe: https://recipes.coopcloud.tech/backup-bot-two


### Docker containers

1. Install dependencies. 

The easiest way to manage the docker image is using just commands.

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

2. Clone this repository and change into the directory:

```sh
git clone --depth 1 https://github.com/bonfire-networks/bonfire-app.git bonfire && cd bonfire
```

3. Specify what flavour you want to run in production:

The first thing to do is choose what flavour of Bonfire (eg. ember, social, community, or cooperation) you want to deploy, as each flavour uses different Docker images and set of configs. For example if you want to run the `social` flavour:

- `export MIX_ENV=prod FLAVOUR=social WITH_DOCKER=yes` 

You may also want to put this in the appropriate place in your system so your choice of flavour is remembered for next time (eg. `~/.bashrc` or `~/.zshrc`)

4. Run `MIX_ENV=prod just config` to initialise some default config and then edit the config in the `./.env` file (see [prepare the config](#preparing-the-config-in-env) for details about what to edit).

> Now that your tooling is set up, you have the choice of using pre-built images or building your own. For example if your flavour does not have a prebuilt image on Docker Hub, or if you want to customise any of the extensions, you can build one yourself. 


#### Using pre-built Docker images (easy mode)

- The `image` entry in `docker-compose.release.yml` will by default use the image on Docker Hub which corresponds to your chosen flavour (see step 1 above for choosing your flavour).

You can see the images available per flavour, version (we currently recommend using the `latest` tag), and architecture at https://hub.docker.com/r/bonfirenetworks/bonfire/tags 

5. Try [running the app](#running-with-docker)!


#### Custom Docker build

Building your own Docker image is useful if you want to make code changes or add your own extensions.

`Dockerfile.release` uses the [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to just the image as small as possible. It generates the OTP release which is later copied into the final image packaged in an Alpine linux container.

There is a `justfile` with relevant commands (make sure set the `MIX_ENV=prod` env variable):

- `just rel-build-locked` which builds the docker image of the latest release
- `just rel-build` which builds the docker image, including local changes to any cloned extensions in `./extensions/` 
- `just rel-tag` adds the "latest" tag to your last build, so that it will be used when running

Once you've built and tagged your image, you may need to update the `image` name in `docker-compose.release.release.yml` to match (either your local image name if running on the same machine you used for the build, or a remote image on Docker Hub if you pushed it) and then follow the same steps as for option A1.

For production, we recommend to set up a CI workflow to automate this, for an example you can look at the one [we currently use](../github/workflows/release.yaml).

Finally, try [running the app](#running-with-docker)!


#### Running with Docker

1. Before running the app for the first time, but after having [prepared the config](#preparing-the-config-in-env), you should run `just setup-prod` which will get the instance ready.

2. The you can start the docker containers with docker-compose: `just rel-run`

You can run this at the prompt `bin/bonfire remote` to enter Elixir's iex environment. Once there in case migrations have not run automatically you can run `Bonfire.Common.Repo.migrate` to initialise your database.

3. The backend should now be running at [http://localhost:4000/](http://localhost:4000/). [Yay, you're up and running!](#notes-on-running-the-app)

4. If that worked, start the app as a daemon to it stays running in the background: `just rel-run-bg`

> Alternatively, `just rel-run-bg db` if you want to run the backend + db but not the web proxy, or `just rel-run-bg db search` if you want to run the full-text search index.


### Bare-metal

Running a custom build without Docker.

1. Install dependencies. 

- Postgres 12+ (but preferably 17+) with [Postgis](https://postgis.net/install/) extension
- [just](https://github.com/casey/just#packages)
- Elixir version 1.15+ with OTP 25+ (see the `.tool-versions` to double check the versions we're currently using). If your distribution only has an old version available, check [Elixir's install page](https://elixir-lang.org/install.html) or use a tool like [mise](https://github.com/jdx/mise) (run `mise install` in this directory) or asdf. 

**Note: Source versions of Elixir >=1.17 and <1.17.3 have bugs that can freeze compilation when using the Pathex library, which bonfire does,** so please use 1.16 or 1.17.3+ (or you can set `WITH_PATHEX=0` in env to disabled the use of that library).

2. Clone this repository and change into the directory:

```sh
git clone --depth 1 https://github.com/bonfire-networks/bonfire-app.git bonfire && cd bonfire
```

3. Specify what flavour you want to run in production:

The first thing to do is choose what flavour of Bonfire (eg. ember, social, community, or cooperation) you want to deploy, as each flavour uses different Docker images and set of configs. For example if you want to run the `social` flavour:

- `export FLAVOUR=social MIX_ENV=prod WITH_DOCKER=no` 

You may also want to put this in the appropriate place in your system so your choice of flavour is remembered for next time (eg. `~/.bashrc` or `~/.zshrc`)

4. Run `just config` to initialise some default config and then edit the config in the `./.env` file (see [prepare the config](#preparing-the-config-in-env) for details about what to edit).
 
5. Run `just setup-prod`

6. Run `just rel-build` to create an elixir release. This will create an executable in your `_build/prod/rel/bonfire` directory. Note that you will need `just` to pass in the `.env` file to the executable, like so: `just cmd _build/prod/rel/bonfire/bin/bonfire <bonfire command>`. Alternatively, this file can be sourced by `source .env` instead. We will be using the `bin/bonfire` executable as called from `just` from here on. 

7. Running the release

- Create a database, and a user, fill out the `.env` with your credentials and secrets

- You will need to use `just` in order to pass the `.env` file to the executable. This can be accomplished by running `just cmd _build/prod/rel/bonfire/bin/bonfire <bonfire command>`. Just works from the root directory of the `justfile`, not your current directory.

- If you’re using RDS or some other locked down DB, you may need to run `CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;` on your database with elevated privileges.

- You may also need to enable the `postgis` extension manually by running `CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;` on your database with elevated privileges.

- You can check if your instance is configured correctly and get to the iex console by running `bin/bonfire start`

- The migrations should automatically run on first boot, but if you run into troubles the migration command is: `Bonfire.Common.Repo.migrate()` in the iex console. 

- To run the instance as a daemon, use `bin/bonfire start daemon`. [Yay, you're up and running!](#notes-on-running-the-app)

8. Adding HTTPS

The common and convenient way for adding HTTPS is by using a reverse proxy like Nginx or Caddyserver (the latter of which is bundled as part of the docker compose setup).

Some web servers (like Caddy or Traefik) can handle generating and setting up HTTPS certificates automatically, but if you need TLS/SSL certificates for nginx, you can look get some for free with [letsencrypt](https://letsencrypt.org/). The simplest way to obtain and install a certificate is to use [Certbot.](https://certbot.eff.org). Depending on your specific setup, certbot may be able to get a certificate and configure your web server automatically.

There is an example nginx configuration provided at `config/deploy/nginx.conf` and one for Caddy at `config/deploy/Caddyfile2-https`

> NOTE: If you've built from source, you should point the web server root directory to be `_build/prod/rel/bonfire/lib/bonfire-[current-version]/priv/static`

### Nix

This repo contains an experimental Flake and Nix module. These are not ready for production.

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


<!-- tabs-close -->


## Preparing the config (in .env)

### Config keys you should pay special attention to:
The app needs these environment variables to be configured in order to work.

- `FLAVOUR` should reflect your chosen flavour
- `HOSTNAME` (your domain name, eg: `bonfire.example.com`)
- `MAIL_BACKEND`, `MAIL_DOMAIN` and `MAIL_KEY` and related keys to configure transactional email, for example set `MAIL_BACKEND=mailgun` and sign up at [Mailgun](https://www.mailgun.com/) and then configure the domain name and key (you may also need to set `MAIL_BASE_URI` if your domain is not setup in EU, as the default `MAIL_BASE_URI` is set as `https://api.eu.mailgun.net/v3`). Many other services and approaches (including SMTP) are available, see [the configuration docs](Bonfire.Mailer.html).
- `UPLOADS_S3_BUCKET` and the related API key and secret for uploads. See `config/runtime.exs` for extra variables available to set if you're not using the default service and region (which is [Scaleway](https://www.scaleway.com/en/object-storage/) Paris).

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
- `bonfire_*.exs`: compile-time configs specific to different extensions, which are automatically imported by `config.exs`
- `[extension]/lib/runtime_config.exs`: runtime configs specific to different extensions, which are automatically imported by `runtime.exs`

You should *not* have to modify the files above. Instead, overload any settings from the above files using env variables or in `./.env`. If any settings in the `.exs` config files are not available in env or in the instance settings UI, please open an issue or PR.


## Notes on running the app

> NOTE: If you are running in a restricted environment such as Amazon RDS, you will need to execute some sql against the database before migrations can run: `CREATE EXTENSION IF NOT EXISTS citext;`

By default, the backend listens on port 4000 (TCP), so you can access it on http://localhost:4000/ (if you are on the same machine) but would usually access it at https://yourdomain.net/. In case of an error it will restart automatically.

You can sign up at https://yourdomain.net/signup even though instances are invite-only by default, if you are the first to sign up you'll be able to do so without email confirmation and will automatically be made an instance admin (where you can then generate invite links or enable open sign ups).

However, for any future sign ups know you will need to having a working [email sending service configured](https://docs.bonfirenetworks.org/Bonfire.Mailer.html) so users can receive confirmation links to verify their email addresses.

> You can also sign up via CLI (accessed via `just rel-shell`) by entering something like this in your app's Elixir console: `Bonfire.Me.make_account_only("my@email.net", "my pw")`


## Handy commands

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

There are some useful database-related release tasks under `EctoSparkles.Migrator.` that can be run in an `iex` console (which you get to with `just rel-shell` followed by `bin/bonfire remote`, assuming the app is already running):

- `migrate` runs all up migrations
- `rollback(step)` roll back to step X
- `rollback_to(version)` roll back to a specific version
- `rollback_all` rolls back all migrations back to zero (caution: this means losing all data)

You can also directly call some functions in the code from the command line, for example:
- to migrate: `docker exec bonfire_web bin/bonfire rpc 'Bonfire.Common.Repo.migrate'`
- to just yourself an admin: `docker exec bonfire_web bin/bonfire rpc 'Bonfire.Me.Users.make_admin("my_username")'`

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
