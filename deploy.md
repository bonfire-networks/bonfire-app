<!--
SPDX-FileCopyrightText: 2025 Bonfire Networks <https://bonfirenetworks.org/contact/>

SPDX-License-Identifier: AGPL-3.0-only
SPDX-License-Identifier: CC0-1.0
-->

# Hosting guide

A short guide to running Bonfire in a production environment and setting up a digital space connected to the fediverse.

> #### Status {: .info}
>  Bonfire Social 1.0 is ready! Other flavours of Bonfire are currently at alpha or beta stages and not ready to use. 

_These instructions are for setting up Bonfire in production. If you want to run the backend in development, please refer to our [Installation guide](./HACKING.md) instead._

> **Before you begin:**  
> Make sure you have completed the [Setup Tutorial](./SETUP.md) to prepare your server, domain, mail, and DNS.  
> This guide assumes your infrastructure is ready and covers installing and configuring Bonfire itself.

---

## Step 1 - Decide how you want to deploy and manage the app

<!-- tabs-open -->

### Co-op Cloud

Install using [Co-op Cloud](https://coopcloud.tech) (recommended) which is an alternative to corporate cloud services built by tech co-ops, and provides handy tools for setting up and managing many self-hosted free software tools using ready-to-use "recipes". Very useful if you'd like to host Bonfire alongside other open and/or federated projects. 

#### 1. Install Coop-Cloud on your server

Follow this [guide to set up Docker and Coop Cloud](https://docs.coopcloud.tech/operators/tutorial/) *on your server*.

If you have any issues connecting with SSH, here's a [guide for coop-cloud ssh issues](https://docs.coopcloud.tech/abra/trouble/#ssh-connection-issues), ensuring you have a `.ssh/config` file set up (locally on your computer):

```
Host [yourdomain.net]
  HostName [yourdomain.net]
  User [your server username, eg. root]
  IdentityFile ~/.ssh/[your_ssh_key]
```

Before proceeding, check that works by running simply `ssh [yourdomain.net]` (without a username) and it should connect using your SSH key (without asking for a password).

#### 2. Install Abra on your computer

[Abra](https://docs.coopcloud.tech/abra/) should be installed *locally on your computer* and acts as the remote control for your Co-op Cloud server, letting you manage software installations more easily from your local machine. 

[Follow the Abra installation guide](https://docs.coopcloud.tech/abra/install/).

##### 2.1. Add your server to Abra

Here's a guide for how to [add your server](https://docs.coopcloud.tech/operators/tutorial/#install-abra) to Abra. Follow that tutorial until you need to install the app: when you reach the part of that guide that mentions Nextcloud, switch back to this guide.

- The command for adding the server is `abra server add [yourdomain.net]` or e.g. `abra server add [social.yourdomain.net]` if using a subdomain
- To see that it works, check `abra server ls` and you'll get a cute happy message

> [!Tip] Protip
> Try pinging *traefik.yourdomain.net* to see that it works:
> `ping traefik.yourdomain.net`

#### 3. Install the web server

[Traefik](https://doc.traefik.io/traefik/) is a proxy that supports developers with publishing services. This will make it easy to ensure that your bonfire instance is up to date! 

Install by following this [recipie to install Traefik](https://recipes.coopcloud.tech/traefik).

Remember to add a valid email when configuring Traefik to generate a SSL certificate (abra app config traefik.yourdomain) - that's the only field you need to configure for traefik to work

#### 4. Install Bonfire

Install the [Bonfire recipe](https://recipes.coopcloud.tech/bonfire) for Co-op Cloud by following these instructions: 

1. `abra app new bonfire --secrets` (optionally with `--pass` if you'd like to save secrets in `pass`) and select your server from the list and enter the domain name you want Bonfire to be served from
2. `abra app config YOUR_APP_DOMAIN_NAME` and check/edit the config keys, see [prepare the config](#preparing-the-config-in-env) for details about what to edit, for example you should add the email sending key:

```
MAIL_BACKEND=mailgun
MAIL_DOMAIN=[yourdomain.net]
MAIL_KEY=[your-mailgun-sending-key]
MAIL_FROM=[from@yourdomain.net]
```

> You can also choose what version of Bonfire to use, by default `APP_VERSION=latest` means it will run the latest stable release (eg. 1.0.0), but if you're conformable testing newer features and improvements (and reporting issues and feedback, please!), you can set `APP_VERSION=latest-rc` for the latest release candidate, or `APP_VERSION=latest-beta`, or even `APP_VERSION=latest-alpha` for the most bleeding edge (and probably most buggy) version
>
> You can also choose a flavour (social is default) by setting e.g. `APP_FLAVOUR=community`

3. `abra app deploy YOUR_APP_DOMAIN_NAME`
6. Open the configured domain in your browser and sign up at at https://yourdomain.net/signup (the instance is invite-only by default, but the first person to sign up bypasses that, and is also automatically an instance admin).

#### CoopCloud FAQs

* How to re-deploy? for example when changing a config in .env or to upgrade to a newer release
	you can force deploy: `abra app deploy [yourdomain.net] --force`

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

* How to sync or share config? to be able to deploy from several computers
	You can turn the `~/abra/servers/yourdomain.net` directory into a git repo and share it (privately!) with collaborators. It's also useful as a backup if you loose access to your machine or want to manager the server from a different place.

### Docker, prebuilt image

Run a ready-made image from Docker Hub. Use this unless you want to change the code or add your own extensions.

`docker-compose.release.yml` starts the app together with a Postgres container, a Sonic search index, and a Caddy reverse proxy. You can replace Caddy with nginx or another proxy.

1. Install [Docker](https://www.docker.com/) with the [compose](https://docs.docker.com/compose/install/#install-compose) plugin. Check that `docker compose version` works.

2. Choose a flavour. The script uses `community` by default. [Docker Hub](https://hub.docker.com/r/bonfirenetworks/bonfire/tags) lists which flavours and architectures have an image. Tags follow the pattern `latest-<flavour>-<arch>`, for example `latest-community-amd64`. To use another flavour, set it first, for example:

```sh
export FLAVOUR=social
```

The setup includes a Caddy reverse proxy that handles HTTPS. If you use your own reverse proxy, leave Caddy out:

```sh
export WITH_PROXY=no
```

Your proxy then forwards to the app on port 4000.

3. Download the preparation script into a new directory, read it, and run it:

```sh
mkdir bonfire && cd bonfire
curl -fsSLO https://raw.githubusercontent.com/bonfire-networks/bonfire-app/main/config/deploy/prepare-docker.sh
less prepare-docker.sh
bash prepare-docker.sh
```

The script downloads the compose file and the config files that the containers use. It creates the env file `config/prod/.env` with generated secrets and the image names for your flavour and architecture, and links `.env` to it. It runs no Docker commands.

You can edit the Caddy, Sonic and Postgres configs that it copies to `config/deploy/`. Run the script again before each upgrade. It updates the other downloaded files, and doesn't change an existing env file. When a template of a config that you can edit changed, it shows the changes and asks whether to keep your copy, or replace it and save yours as a `.bak` file. The same check runs in the `just` setups, when they start the containers.

4. Edit `config/prod/.env`. Set at least `HOSTNAME` and the `MAIL_*` keys (see [prepare the config](#preparing-the-config-in-env)). Also:
   - If you set `PUBLIC_PORT=443`, also set `PROXY_CADDYFILE_PATH=./config/deploy/Caddyfile2-https`.
   - To add or remove the Caddy proxy later, add or remove `proxy` in `COMPOSE_PROFILES`.

5. Download the images: `docker compose pull`

6. Start the app in the foreground to check that it works: `docker compose up`. The migrations run on the first start. The app runs at [http://localhost:4000/](http://localhost:4000/). [Yay, you're up and running!](#notes-on-running-the-app)

7. Stop it with Ctrl+C, then start it in the background: `docker compose up -d`

Useful commands, in the same directory:
- Logs: `docker compose logs -f web`
- IEx console: `docker compose exec web bin/bonfire remote`
- Upgrade: `bash prepare-docker.sh`, then `docker compose pull && docker compose up -d`
- Stop: `docker compose stop`

### Docker, custom build

Build your own image. Use this to change the code, add your own extensions, or run a flavour that has no image on [Docker Hub](https://hub.docker.com/r/bonfirenetworks/bonfire/tags).

`Dockerfile.release` uses a [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) to keep the image small. It builds the OTP release, then copies it into an Alpine Linux image.

1. Install [Docker](https://www.docker.com/) with the [compose](https://docs.docker.com/compose/install/#install-compose) plugin, and [just](https://github.com/casey/just#packages). Check that `docker compose version` and `just --version` work.

2. Clone this repository and change into the directory:

```sh
git clone --depth 1 https://github.com/bonfire-networks/bonfire-app.git bonfire && cd bonfire
```

3. Choose a flavour, for example `community`:

```sh
export MIX_ENV=prod FLAVOUR=community WITH_DOCKER=yes
```

Add this line to your shell profile (eg. `~/.bashrc` or `~/.zshrc`) so that `just` remembers your choice next time.

4. Run `just config` to create the `.env` file, then edit it (see [prepare the config](#preparing-the-config-in-env)).

5. Run `just setup-prod-build`. This fetches the flavour's extensions and dependencies.

6. Build the image with one of these:
- `just rel-build` builds with the committed and pushed version of each extension. It ignores local changes in `./extensions/`.
- `just rel-build-with-clones` includes local changes in `./extensions/`.

Arguments after the recipe name go to `docker build`, for example `just rel-build --no-cache`.

7. Run `just rel-tag`. This tags your last build as `bonfirenetworks/bonfire:latest-<flavour>-<arch>`, which is the image that `docker-compose.release.yml` uses by default. To use an image with another name, for example one you pushed to a registry, set `APP_DOCKER_IMAGE` in `.env`.

8. [Run the app](#running-with-docker).

For production, we recommend a CI workflow that builds your images. For an example, see [the one we use](../.github/workflows/release.yaml).


### Bare-metal, prebuilt release

Run a release tarball without Docker and without a build step. The tarball includes the Erlang runtime, so you don't need Erlang or Elixir on the server. This works with or without root access.

You need a Postgres database, see [Database](#database-bare-metal).

1. Choose a tarball. The [GitHub releases](https://github.com/bonfire-networks/bonfire-app/releases) page lists the available tarballs under "Assets" for each release. The file names follow the pattern `bonfire-<flavour>-<arch>-<distro>.tar.gz`. Each tarball is built on its target distro, so choose the one that matches your server:
   - `debian-bookworm` for Debian 12
   - `rhel-9` for RHEL 9 and compatible distros, such as Rocky Linux 9 or AlmaLinux 9

If there is no tarball for your flavour, architecture or distro, use the "Bare-metal, build from source" tab or Docker.

2. Set your choice of tarball, and choose where to install. As root, put the app in `/opt/bonfire`, put the env file in `/etc/bonfire`, and create a system user to run the app. Without root, put both in a directory in your home.

```sh
export FLAVOUR=community
export DISTRO=rhel-9    # or debian-bookworm

# As root:
BONFIRE_DIR=/opt/bonfire
ENV_FILE=/etc/bonfire/.env
useradd --system --home "$BONFIRE_DIR" --shell /sbin/nologin bonfire

# Without root:
BONFIRE_DIR=$HOME/bonfire
ENV_FILE=$HOME/bonfire/.env
```

These variables last for the current shell session only. The next steps use them.

3. Download and extract the tarball:

```sh
mkdir -p "$BONFIRE_DIR"
curl -L "https://github.com/bonfire-networks/bonfire-app/releases/latest/download/bonfire-$FLAVOUR-amd64-$DISTRO.tar.gz" | tar -xz -C "$BONFIRE_DIR" --strip-components=1
```

`releases/latest/download/` gets the latest stable release. For a pre-release, copy the tarball link from its release page.

4. Create the env file. The tarball doesn't include the templates, so download them from the repository:

```sh
mkdir -p "$(dirname "$ENV_FILE")"
curl -L https://raw.githubusercontent.com/bonfire-networks/bonfire-app/main/config/templates/public.env https://raw.githubusercontent.com/bonfire-networks/bonfire-app/main/config/templates/not_secret.env > "$ENV_FILE"
chmod 600 "$ENV_FILE"
```

5. Generate the secrets and set the flavour. Save this script as `keys-generator.sh`:

```shell
#!/usr/bin/env bash

rand() {
  openssl rand -base64 "$1" | tr -d '\n/+=' | head -c "$1"
  echo
}

env_file=$(readlink -f "${1:-.env}")

set_var() {
  key="$1"
  value="$2"

  if grep -q "^${key}=" "$env_file" 2>/dev/null; then
    # Replace existing key
    sed -i "s|^${key}=.*|${key}=${value}|" "$env_file"
  else
    # Append if not found
    echo "${key}=${value}" >> "$env_file"
  fi
}

set_var "FLAVOUR" "${FLAVOUR:?Set FLAVOUR first, see step 2}"
set_var "SECRET_KEY_BASE" "$(rand 128)"
set_var "SIGNING_SALT" "$(rand 128)"
set_var "ENCRYPTION_SALT" "$(rand 128)"
set_var "RELEASE_COOKIE" "$(rand 42)"
set_var "POSTGRES_PASSWORD" "$(rand 42)"
set_var "SONIC_PASSWORD" "$(rand 42)"

echo "Updated $env_file"
```

Then run it: `bash keys-generator.sh "$ENV_FILE"`

6. Edit the env file (eg. `nano "$ENV_FILE"`) and set at least these values (see [prepare the config](#preparing-the-config-in-env) for the others):
   - `HOSTNAME`
   - `POSTGRES_HOST`, `POSTGRES_USER` and `POSTGRES_DB`. The script generated a random `POSTGRES_PASSWORD`, so set the database user's password to the same value, or replace it with the existing password. You can set `DATABASE_URL=ecto://USER:PASS@HOST/DATABASE` instead of these four.
   - The `MAIL_*` keys

7. As root, give the app's user ownership of its files:

```sh
chown -R bonfire:bonfire "$BONFIRE_DIR" "$(dirname "$ENV_FILE")"
```

8. [Run the app as a service](#run-as-a-service-bare-metal).

### Bare-metal, build from source

Build the release yourself, without Docker. Use this to change the code, add your own extensions, or run a flavour, architecture or distro that has no prebuilt tarball. This works with or without root access.

1. Install the dependencies:
   - Postgres, see [Database](#database-bare-metal)
   - [just](https://github.com/casey/just#packages)
   - Elixir 1.15+ with OTP 25+ (see `.tool-versions` for the versions we use). If your distribution only has an older version, see [Elixir's install page](https://elixir-lang.org/install.html), or use a tool like [mise](https://github.com/jdx/mise) (run `mise install` in this directory) or asdf.

**Note: Source versions of Elixir >=1.17 and <1.17.3 have bugs that can freeze compilation when using the Pathex library, which bonfire does,** so please use 1.16 or 1.17.3+ (or you can set `WITH_PATHEX=0` in env to disable the use of that library).

2. Clone this repository and change into the directory:

```sh
git clone --depth 1 https://github.com/bonfire-networks/bonfire-app.git bonfire && cd bonfire
```

3. Choose a flavour, for example `community`:

```sh
export MIX_ENV=prod FLAVOUR=community WITH_DOCKER=no
```

Add this line to your shell profile (eg. `~/.bashrc` or `~/.zshrc`) so that `just` remembers your choice next time.

4. Run `just config` to create the `.env` file, then edit it (see [prepare the config](#preparing-the-config-in-env)). Put your database credentials in it.

5. Run `just setup-prod`. This fetches the flavour's extensions and dependencies.

6. Build the release in `_build/prod/rel/bonfire` with one of these:
- `just rel-build` builds with the committed and pushed version of each extension. It ignores local changes in `./extensions/`.
- `just rel-build-with-clones` includes local changes in `./extensions/`.

7. Check that the release starts: `just cmd _build/prod/rel/bonfire/bin/bonfire start`. `just cmd` loads `.env` and runs from the directory of the `justfile`. The migrations run on the first start. If they don't, connect with `just cmd _build/prod/rel/bonfire/bin/bonfire remote` and run `Bonfire.Common.Repo.migrate()`.

8. Copy the release and the env file to their permanent location:

```sh
# As root:
cp -r _build/prod/rel/bonfire /opt/bonfire
mkdir -p /etc/bonfire
cp -L .env /etc/bonfire/.env
chmod 600 /etc/bonfire/.env
useradd --system --home /opt/bonfire --shell /sbin/nologin bonfire
chown -R bonfire:bonfire /opt/bonfire /etc/bonfire

# Without root:
cp -r _build/prod/rel/bonfire ~/bonfire
cp -L .env ~/bonfire/.env
chmod 600 ~/bonfire/.env
```

9. [Run the app as a service](#run-as-a-service-bare-metal).

### Guix

[Guix](https://guix.gnu.org) is a functional, atomic, transactional package manager and Linux distribution. It was inspired by Nix and is designed to give users more control over their computing environments, and make these easier to reproduce over time and deploy to one or many devices.

The [`bonfire-guix`](https://github.com/bonfire-networks/bonfire-guix) channel contains a Guix System service to deploy Bonfire. Assuming you have the Guix System installed on a server the following steps will allow you to have a working Bonfire instance.  You can find a more detailed guide [here](https://fishinthecalculator.me/blog/bonfire--guix-a-love-story.html).

#### 1. Enable the `bonfire-guix` channel

You can follow [these instructions](https://github.com/bonfire-networks/bonfire-guix?tab=readme-ov-file#configure) to make Guix aware of the Bonfire channel. You can check you have correctly enabled `bonfire-guix` by running `guix describe`. After `guix pull`, in a new shell, your `guix describe` should look something like this (commit hashes will probably differ):

```shell
Generation 42   Oct 06 2025 18:39:20    (current)
  guix 7a0c6b4
    repository URL: https://git.guix.gnu.org/guix.git
    branch: master
    commit: 7a0c6b4b0a72a47035486a6b72dc67014b8a64ce
  bonfire 49617fa
    repository URL: https://github.com/bonfire-networks/bonfire-guix
    branch: main
    commit: 49617fa523bf66de8193ef5b004beea95ef1b133
  sops-guix eba0aae
    repository URL: https://github.com/fishinthecalculator/sops-guix
    branch: main
    commit: eba0aae6ac9d828c1afe7f8275ac8e1094334286
  gocix aea12b4
    repository URL: https://github.com/fishinthecalculator/gocix
    branch: main
    commit: aea12b4088799e436e6a1ccc479854ac55cb99c0
```

#### 2. Setup SSL certificates

You want to setup SSL certificates provisioning as soon as possible, since everything from now on presupposes HTTPS. To do so on the Guix System, you have to add the `certbot-service-type` to your `operating-system` record (which after installation is available in `/etc/config.scm`):

```scheme
(use-modules (gnu services certbot) ...) ;for 'certbot-service-type'

(operating-system
  ...

  (services
    (list
      ...
      (service certbot-service-type
               (certbot-configuration
                (email "your@email.org")
                (certificates
                 (list
                  (certificate-configuration
                   (domains (list "yourdomain.net"))))))))))
```

Reconfigure your system with `sudo guix system reconfigure` and proceed with the next steps.

#### 3. Secrets

The Bonfire service is able to load secrets stored as files, so you are free to choose whichever option you prefer to provision and rotate them. One option to provision secrets as files in a Guix aware way is [sops-guix](https://github.com/fishinthecalculator/sops-guix). You can refer to [`sops-guix`' tutorial for a more in depth explaination](https://github.com/fishinthecalculator/sops-guix?tab=readme-ov-file#creating-secrets-with-sops).

##### `age` keys

First you need a set of cryptographic keys to encrypt your secrets, in this example [`age`](https://age-encryption.org) will be used. If you already have your `age` keys, skip to the **SOPS secrets** section.

Run the following on server to generate keys for the `root` account:

```shell
~$ sudo -i
Password: 
~# mkdir -p ~/.config/sops/age
~# guix shell age -- age-keygen -o /root/.config/sops/age/keys.txt
...

Public key: age1m3hcq7d9sl3d0uz6ezxvns4f7mjctksmmf5d8tpptmyz30rk9qnscgzfsa
```

You'll need one keypair for each user of the secret so, if you intend to be able to update secrets on a different machine than the one you are installing Bonfire on, make sure to generate a keypair there as well. If you are creating secrets on a PC or a laptop and intend to run Bonfire on a server you SSH into, this is your scenario. Create one keypair for your user on your machine at `$HOME.config/sops/age/keys.txt` with the above command.

Next you need to create a SOPS configuration file, named `.sops.yaml`, in the same directory your Guix configuration file is:

```yaml
keys:
    # This is the public key of your laptop/PC
    - &user_yourself_age age1peu96695en0xrlshkd3j3zzd04payh3cx27yjw6r40z8ekemnuesmkrupn
    # This is the public key of the server you are installing Bonfire upon
    - &host_yoursystem age1m3hcq7d9sl3d0uz6ezxvns4f7mjctksmmf5d8tpptmyz30rk9qnscgzfsa

creation_rules:
    - path_regex: .*yoursystem\.yaml$
      key_groups:
          - age:
                - *user_yourself_age
                - *host_yoursystem
```

You are now ready to create the [secrets you need](#secret-keys-for-which-you-should-put-random-secrets).

##### SOPS secrets

In this example the PostgreSQL password secret is being created, but other secrets are created the same way. You can generate a random string with:

```shell
guix shell openssl -- openssl rand -base64 32
v/hSYQHNCJMYW+U8D3m6ADQ+5382jN9iJ69gfImEISY=
```

From the same directory where the `.sops.yaml` and your configuration are stored, run the following command to create a `yoursystem.yaml` file that will store your encrypted secrets. Unencrypted secrets are supposed to never hit the disk, check out `sops-guix` README for more information.

```bash
guix shell sops -- sops yoursystem.yaml
```

Your default editor will pop up. Replace the SOPS example secrets and add the following content to the file:

```yaml
postgres:
    bonfire: v/hSYQHNCJMYW+U8D3m6ADQ+5382jN9iJ69gfImEISY=
```

Save and close the editor. You can now check inside `yoursystem.yaml` and see that the secrets is effectively encrypted.

When all secrets are in your `yoursystem.yaml` file your can add the following to your operating system configuration:

```scheme
(use-modules (guix gexp)            ;for 'local-file'
             (guix utils)           ;for 'current-source-directory'
             (sops services sops)   ;for 'sops-secrets-service-type' and 'sops-secret->secret-file'
             (sops secrets)         ;for 'sops-secret'
             ...)

(define %project-root
 (current-source-directory))

(define sops.yaml
  (local-file (string-append %project-root "/.sops.yaml")
              "sops.yaml"))

(define-public yoursystem.yaml
  (local-file (string-append %project-root "/yoursystem.yaml")
              "yoursystem.yaml"))

;; PostgreSQL

(define-public bonfire-postgres-password-secret
  (sops-secret
   ;; Each element of this list represents
   ;; one key in yoursystem.yaml.  In this case
   ;; it represents:
   ;;
   ;; postgres:
   ;;      bonfire:
   ;;
   (key '("postgres" "bonfire"))
   (user "oci-container")
   (group "postgres")
   (file yoursystem.yaml)
   (permissions #o440)))

;; Meilisearch

(define-public meilisearch-key-secret
  (sops-secret ...))

;; Bonfire

(define-public bonfire-mail-key-secret
  (sops-secret ...))
   
(define-public bonfire-mail-private-key-secret
  (sops-secret ...))

(define-public bonfire-secret-key-base-secret
  (sops-secret ...))

(define-public bonfire-signing-salt-secret
  (sops-secret ...))

(define-public bonfire-encryption-salt-secret
  (sops-secret ...))

(operating-system
  ...

  (services
    (list
      ...
      (service sops-secrets-service-type
               (sops-service-configuration
                (config sops.yaml)
                (secrets
                 (list meilisearch-key-secret
                       bonfire-postgres-password-secret
                       bonfire-mail-key-secret
                       bonfire-mail-private-key-secret
                       bonfire-secret-key-base-secret
                       bonfire-signing-salt-secret
                       bonfire-encryption-salt-secret)))))))
```

#### 4. Postgres

Bonfire supports the PostgreSQL database engine and requires the postgis extension. At the time of this writing Guix will by default will install PostgresSQL 16 but you can use another version by [setting the `postgresql` field of the `postgresql-configuration`](https://guix.gnu.org/manual/devel/en/guix.html#index-postgresql_002dconfiguration). This is what it's required to set them up:

```scheme
(use-modules (gnu packages geo)        ;for postgis
             (gnu packages databases)  ;for 'postgresql'
             (gnu services databases)  ;for 'postgresql-service-type'
             ...)


(operating-system
  ...

  (services
    (list
      ...

      ;; Postgres
      (service postgresql-service-type
               (postgresql-configuration
                (postgresql postgresql)))
                (extension-packages (list postgis)))))))
```

#### 5. Podman

Add the `rootless-podman-service-type` and it DBus dependencies to your configuration in the `services` field:

```scheme
(use-modules (gnu services containers) ;for 'rootless-podman-service-type' and 'oci-service-type'
             (gnu services dbus)       ;for 'dbus-service-type'
             (gnu services desktop)    ;for 'elogind-service-type'
             ...)

...

;; The DBus clique
(service elogind-service-type)
(service dbus-root-service-type)

;; Podman
(service rootless-podman-service-type)

;; This service implements OCI provisioned Shepherd services
(service oci-service-type
         (oci-configuration
          (runtime 'podman)))
```

#### 6. Meilisearch and Bonfire

To provision a functional Bonfire instance you will need two services, meilisearch and the Bonfire flavour. The `(bonfire services bonfire)` module provides a Guix System service able to provision a database and the Bonfire instance. Add the following to your `operating-system` configuration, and make sure to change the values based on your actual setup:

```scheme
(use-modules (bonfire services bonfire) ;for 'oci-bonfire-service-type'
             (oci services meilisearch) ;for 'oci-meilisearch-service-type'
             ...)

...

;; meilisearch
(service oci-meilisearch-service-type
         (oci-meilisearch-configuration
          (network "host")
          (shepherd-requirement '(user-processes sops-secrets))
          (master-key
           ;; In case you are not using sops-guix for your secrets
           ;; just pass the secret file path as a string.
           ;; The same holds for all other secrets fields.
           (sops-secret->secret-file meilisearch-key-secret))))

;; Bonfire
(service oci-bonfire-service-type
         (oci-bonfire-configuration
          (configuration
           (bonfire-configuration
            ;; Networking
            (hostname "yourdomain.net")  ;replace with your domain
            (public-port "443")
            (network "host")
            ;; Postgres
            (postgres-user "bonfire")
            (postgres-db "bonfire")
            ;; Mail
            (mail-domain "yourdomain.net")
            (mail-from "youremail@address.org")))
          ;; Shepherd dependencies
          (requirement
           '(user-processes postgresql postgres-roles podman-meilisearch sops-secrets))
          (extra-variables
           `(("MAIL_BACKEND" . "mailjet") ;; change with your email provider
             ("SERVER_PORT" . "4000")
             ("SEARCH_MEILI_INSTANCE" . "http://localhost:7700")))
          ;; Secrets
          (meili-master-key
           (sops-secret->secret-file meilisearch-key-secret))
          (postgres-password
           (sops-secret->secret-file bonfire-postgres-password-secret))
          (mail-key
           (sops-secret->secret-file bonfire-mail-key-secret))
          (mail-private-key
           (sops-secret->secret-file bonfire-mail-private-key-secret))
          (secret-key-base
           (sops-secret->secret-file bonfire-secret-key-base-secret))
          (signing-salt
           (sops-secret->secret-file bonfire-signing-salt-secret))
          (encryption-salt
           (sops-secret->secret-file bonfire-encryption-salt-secret))))
```

#### 7. Reverse proxy

The last piece to be able to access your instance from the Internet is a reverse proxy. We'll use NGINX but any one should work. To configure NGINX to forward traffic to Bonfire the following must be added to your configuration:

```scheme
(use-modules (gnu services web) ;for 'nginx-service-type'
             ...)

...

(service nginx-service-type
         (nginx-configuration
          ;; Wait for Bonfire to start
          (shepherd-requirement '(podman-bonfire))
          (server-blocks
           (list
            (nginx-server-configuration
             (server-name (list "yourdomain.net"))
             (listen '("443 ssl" "[::]:443 ssl"))
             ;; Replace with your domain
             (ssl-certificate "/etc/certs/yourdomain.net/fullchain.pem")
             ;; Replace with your domain
             (ssl-certificate-key "/etc/certs/yourdomain.net/privkey.pem")
             (locations
              (list
               (nginx-location-configuration
                (uri "/")
                (body (list (string-append "proxy_pass http://localhost:4000;")
                ;; Taken from https://www.nginx.com/resources/wiki/start/topics/examples/full/
                ;; Those settings are used when proxies are involved
                "proxy_redirect          off;"
                "proxy_set_header        Host $host;"
                "proxy_set_header        X-Real-IP $remote_addr;"
                "proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;"
                "proxy_http_version      1.1;"
                "proxy_cache_bypass      $http_upgrade;"
                "proxy_set_header        Upgrade $http_upgrade;"
                "proxy_set_header        Connection \"upgrade\";"
                "proxy_set_header        X-Forwarded-Proto $scheme;"
                "proxy_set_header        X-Forwarded-Host  $host;")))
               ;; Statically serve uploaded media.
               (nginx-location-configuration
                (uri "/data/uploads/")
                (body
                 (list "alias /var/lib/bonfire/uploads/;"
                       "index  index.html index.htm;"
                       ;; uploads (e.g. SVG) are served from the instance's origin, so stop any script in them from running if opened directly
                       "add_header Content-Security-Policy \"sandbox; default-src 'none'; style-src 'unsafe-inline'\" always;"))))))))))
```

<!-- tabs-close -->


## Preparing the config (in .env)

### Config keys you should pay special attention to:
The app needs these environment variables to be configured in order to work.

- `FLAVOUR` should reflect your chosen flavour
- `HOSTNAME` (your domain name, eg: `bonfire.example.com`)
- `MAIL_BACKEND`, `MAIL_DOMAIN` and `MAIL_KEY` and related keys to configure transactional email, for example set `MAIL_BACKEND=mailgun` and sign up at [Mailgun](https://www.mailgun.com/) and then configure the domain name and key (you may also need to set `MAIL_BASE_URI` if your domain is not setup in EU, as the default `MAIL_BASE_URI` is set as `https://api.eu.mailgun.net/v3`). Many other services and approaches (including SMTP) are available, see [the configuration docs](Bonfire.Mailer.html).
  - If you use `MAIL_BACKEND=smtp`, set `MAIL_SERVER`, `MAIL_USER` and `MAIL_PASSWORD` (plus optionally `MAIL_PORT` and `MAIL_SSL`) instead of `MAIL_KEY`. Do **not** set both `MAIL_KEY` and `MAIL_PASSWORD`: `MAIL_KEY` takes precedence, so a leftover `MAIL_KEY` from a previous API-based backend will be sent as your SMTP password and authentication will fail (eg. `535 5.7.8`). Remove `MAIL_KEY` from the environment and redeploy so the runtime config is reloaded.
- `UPLOADS_S3_BUCKET` and the related API key and secret for uploads. See `config/runtime.exs` for extra variables available to set if you're not using the default service and region (which is [Scaleway](https://www.scaleway.com/en/object-storage/) Paris).

### Secret keys for which you should put random secrets. 
You can run `just secrets` to generate some for you.

- `SECRET_KEY_BASE`
- `SIGNING_SALT`
- `ENCRYPTION_SALT`
- `RELEASE_COOKIE`
- `POSTGRES_PASSWORD`
- `SONIC_PASSWORD`

### Further information on config

In the `./config/` (which is a symbolic link to the config of the flavour you choose to run) directory of the codebase, there are following config files:

- `config.exs`: default base configuration, which itself loads many other config files, such as one for each installed Bonfire extension.
- `prod.exs`: default extra configuration for `MIX_ENV=prod`
- `runtime.exs`: extra configuration which is loaded at runtime (vs the others which are only loaded once at compile time, i.e. when you build a release)
- `bonfire_*.exs`: compile-time configs specific to different extensions, which are automatically imported by `config.exs`
- `[extension]/lib/runtime_config.exs`: runtime configs specific to different extensions, which are automatically imported by `runtime.exs`

You should *not* have to modify the files above. Instead, overload any settings from the above files using env variables or in `./.env`. If any settings in the `.exs` config files are not available in env or in the instance settings UI, please open an issue or PR.


## Database (bare-metal)

The Docker and Co-op Cloud setups run Postgres for you. On bare-metal, install Postgres 12+ (preferably 17+) with the [PostGIS](https://postgis.net/install/) extension, then create a database and a user for Bonfire.

Put the credentials in the env file: `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_DB` and `POSTGRES_PASSWORD`, or `DATABASE_URL=ecto://USER:PASS@HOST/DATABASE` instead.

The migrations run when the app starts. If the Bonfire database user can't create extensions (for example on Amazon RDS or another locked-down database), run this on the database as a privileged user first:

```sql
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
```

## Running with Docker

1. Start the containers: `just rel-run`. This opens an IEx console attached to the app. The migrations run on start. If they don't, run `Bonfire.Common.Repo.migrate` in the console.

2. The app now runs at [http://localhost:4000/](http://localhost:4000/). [Yay, you're up and running!](#notes-on-running-the-app)

3. If that works, stop it and start it in the background so that it keeps running: `just rel-run-bg`

> Alternatively, `just rel-run-bg db` if you want to run the backend + db but not the web proxy, or `just rel-run-bg db search` if you want to run the full-text search index as well.

## Run as a service (bare-metal)

Use a process supervisor so that Bonfire restarts after a crash or a reboot. These examples use systemd. Other supervisors (eg. OpenRC or runit) also work, if they run `bin/bonfire start` in the foreground and restart it on failure.

Don't use `bin/bonfire daemon` under a supervisor. It detaches from the supervisor, and it writes its logs to `tmp/log/` in the release directory instead of the journal.

### As root

The provided unit file [config/templates/bonfire.service](../config/templates/bonfire.service) expects the release in `/opt/bonfire`, the env file at `/etc/bonfire/.env`, and a `bonfire` system user. Edit it if your setup is different.

```sh
curl -L https://raw.githubusercontent.com/bonfire-networks/bonfire-app/main/config/templates/bonfire.service -o /etc/systemd/system/bonfire.service
systemctl daemon-reload
systemctl enable --now bonfire
systemctl status bonfire
```

### Without root

1. Save this as `~/.config/systemd/user/bonfire.service`. `%h` is your home directory, so change the paths if you installed elsewhere than `~/bonfire`:

```ini
[Unit]
Description=Bonfire
After=network.target

[Service]
Type=exec
WorkingDirectory=%h/bonfire
EnvironmentFile=%h/bonfire/.env
ExecStart=%h/bonfire/bin/bonfire start
ExecStop=%h/bonfire/bin/bonfire stop
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

2. Start it:

```sh
systemctl --user daemon-reload
systemctl --user enable --now bonfire
systemctl --user status bonfire
```

3. Run `loginctl enable-linger` once. Without it, systemd stops your services when you log out, and doesn't start them at boot. If this fails, ask an admin to run `sudo loginctl enable-linger <your_user>`.

Add `--user` to every `systemctl` and `journalctl` command for this service, for example `systemctl --user restart bonfire`.

### Sonic search

The env templates set `SEARCH_ADAPTER=sonic`. In this case, run [Sonic](https://github.com/valeriansaliou/sonic#installation) as a second service:

1. Install Sonic. Copy [config/templates/sonic.cfg](../config/templates/sonic.cfg) next to it, then edit the copy. Change the `store` paths to a directory that the service's user can write to. Change `inet` to `127.0.0.1:1491` if Sonic runs on the same server as Bonfire.

2. Create a unit for it. For example without root, save this as `~/.config/systemd/user/sonic.service`. Sonic reads its password from `SONIC_CHANNEL__AUTH_PASSWORD`, so the unit sets it from `SONIC_PASSWORD` in Bonfire's env file:

```ini
[Unit]
Description=Sonic search backend
After=network.target

[Service]
EnvironmentFile=%h/bonfire/.env
ExecStart=/usr/bin/env SONIC_CHANNEL__AUTH_PASSWORD=${SONIC_PASSWORD} %h/sonic/sonic -c %h/sonic/sonic.cfg
Restart=on-failure

[Install]
WantedBy=default.target
```

As root, put it in `/etc/systemd/system/`, use absolute paths instead of `%h`, add `User=bonfire`, and set `WantedBy=multi-user.target`.

3. In `bonfire.service`, add `Wants=sonic.service` and `After=sonic.service` in the `[Unit]` section. Then run `systemctl daemon-reload` (with `--user` for user units) and enable both services.

### Open a console

To connect an IEx console to the running app, load the env file first, so that the console uses the same node name and cookie:

```sh
set -a; . /etc/bonfire/.env; set +a    # or ~/bonfire/.env without root
/opt/bonfire/bin/bonfire remote        # or ~/bonfire/bin/bonfire
```

### View logs

systemd sends the app's output to the journal. Add `--user` to these commands if you run Bonfire without root:

```sh
journalctl -u bonfire -f                      # follow live
journalctl -u bonfire -n 200                  # last 200 lines
journalctl -u bonfire --since "1 hour ago"
journalctl -u bonfire -p err                  # errors only
```

To find an error message and the lines around it, use `grep -C` (`-B` and `-A` set the lines before and after separately):

```sh
journalctl -u bonfire --since today --no-pager | grep -n -F -B 5 -A 50 "your error text"
```

If `journalctl` shows nothing or prints "You are currently not seeing messages from other users", your user can't read the journal. Some distros (eg. RHEL) keep the journal in memory by default, and then logs from user services go to the system journal. To fix this, do one of these as root:

- Add the user to the `systemd-journal` group: `usermod -aG systemd-journal <your_user>`, then log in again.
- Make the journal persistent, so each user gets their own journal file: `mkdir -p /var/log/journal && systemctl restart systemd-journald`.

You can also see live logs in the admin UI at `/admin/system/`.

## Reverse proxy and HTTPS (bare-metal)

Put a reverse proxy in front of the app (which listens on port 4000) to add HTTPS. The Docker setup includes Caddy.

Caddy and Traefik can get HTTPS certificates for you. For nginx or Apache, you can get free certificates from [Let's Encrypt](https://letsencrypt.org/), for example with [Certbot](https://certbot.eff.org). Certbot can sometimes also configure your web server for you.

Copy the template for your web server into its config directory, then edit the copy. Without a clone of this repository, download the template first, for example `curl -LO https://raw.githubusercontent.com/bonfire-networks/bonfire-app/main/config/templates/nginx.conf`.

The app stores uploads in `data/uploads/` inside its working directory (`/opt/bonfire` as root, `~/bonfire` without root).

- nginx: [config/templates/nginx.conf](../config/templates/nginx.conf) has only the `location` blocks. Put them in a `server` block with your `server_name`, `listen 443 ssl` and certificate lines, for example in `/etc/nginx/conf.d/bonfire.conf`. Change `root priv/static` to the absolute path of the static files: `lib/bonfire-<version>/priv/static` inside the release directory. The version in this path changes when you upgrade.
- Caddy: [config/templates/Caddyfile2-https](../config/templates/Caddyfile2-https) is written for the Docker setup. Copy it to `/etc/caddy/Caddyfile`, then replace `:443` with your domain (so that Caddy gets a certificate for it), `web:4000` with `127.0.0.1:4000`, and `/frontend/` with the app's working directory.
- Apache: copy [config/templates/apache.conf](../config/templates/apache.conf) to `/etc/httpd/conf.d/bonfire.conf` (RHEL), or to `/etc/apache2/sites-available/bonfire.conf` and run `a2ensite bonfire` (Debian). Change `ServerName`, the certificate and log paths, and the uploads `Alias` and `<Directory>` paths, which must point to `data/uploads/` inside the app's working directory. It needs the `proxy`, `proxy_http`, `proxy_wstunnel`, `rewrite`, `headers` and `ssl` modules. This is a `<VirtualHost>` block, so it needs admin access. It doesn't work in a `.htaccess` file, because `.htaccess` doesn't allow `Alias` or `ProxyPass`.


## Notes on running the app

By default, the backend listens on port 4000 (TCP), so you can access it on http://localhost:4000/ (if you are on the same machine) but would usually access it at https://yourdomain.net/. In case of an error it will restart automatically.

You can sign up at https://yourdomain.net/signup even though instances are invite-only by default, if you are the first to sign up you'll be able to do so without email confirmation and will automatically be made an instance admin (where you can then generate invite links or enable open sign ups).

> You can also sign up via CLI (accessed via `just rel-shell`) by entering something like this in your app's Elixir console: `Bonfire.Me.make_account_only("my@email.net", "my pw")`

For any future sign ups know you will need to having a working [email sending service configured](https://docs.bonfirenetworks.org/Bonfire.Mailer.html) so users can receive confirmation links to verify their email addresses.

> By default sign ups are by invite only. You can invite people via instance settings, or open up for public registrations (just make sure you have a code of conduct and moderation team in place first). 

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
- to make yourself an admin: `docker exec bonfire_web bin/bonfire rpc 'Bonfire.Me.Users.make_admin("my_username")'`

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
