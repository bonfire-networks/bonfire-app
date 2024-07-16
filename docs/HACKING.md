# Installation

> #### Info {: .info}
>
> These instructions are for hacking on Bonfire. If you wish to deploy in production, please refer to our deployment guide instead.



Hello, potential contributor! :-)

This is a work in progress guide to getting up and running as a developer. Please ask questions in the issue tracker if something is not clear and we'll try to improve it.

Happy hacking!

## Status: beta - have fun and provide feedback 🙏

Bonfire is currently beta software. While it's fun to play with it, we would not recommend running any production instances (meaning not using it for your primary fediverse identity) yet because it's not quite ready for that today. 

## System Requirements

- [Just](https://github.com/casey/just#packages): a handy tool (a `make` alternative) to run commands defined in `./justfile`.

## Download

Either way, you need to first clone this repository and change into the directory and then do some configuration:

```sh
$ git clone https://github.com/bonfire-networks/bonfire-app bonfire
$ cd bonfire
```

## Configure

### Pick a flavour

Bonfire is a flexible platform that powers a variety of social networks. The first thing you have to choose is which app (or "flavour") you want to hack on:

- `classic` ("Bonfire Social", a basic social network that interoperates with the fediverse)
- `community` (for topics and groups)
- `open-science` (for next-gen scientific communities)
- `coordination` (for coordinating around tasks and projects)
- `cooperation` (for building cooperative economic networks)

Note that at the current time, the core team are focusing most of their efforts on the `classic` flavour and this is where we **recommend** you start.


So for example if you want to run the `classic` flavour run:

```sh
export FLAVOUR=classic
``` 

You may also want to put this in the appropriate place in your system so your choice of flavour is remembered for next time (eg. `~/.bashrc` or `~/.zshrc`)


### Choose your development environment

You can choose to run bonfire in a variety of ways, from fully managed via docker-compose, to bare metal with local postgres and elixir, to a combination of the two, we also offer the possibility to run Bonfire with nix.

<!-- tabs-open -->

### Total

The entry-way is fully managed via docker-compose, recommended when you're first exploring

#### Dependencies 

- Recent versions of Docker & [docker-compose](https://docs.docker.com/compose/install/)
- Make sure you've set the environment variable to indicate your choice:

```bash
export WITH_DOCKER=total
```

### Easy

The easy way consist in using bare-metal elixir, and docker-managed tooling, database & search index, recommended for active development.

> #### Info {: .info}
>
> Note: you can use a tool like [mise](https://mise.jdx.dev/) or asdf to setup the environment (run `mise install` in the root directory).


#### Dependencies:
  - Recent versions of [Elixir](https://elixir-lang.org/install.html) (1.15+) and OTP/erlang (25+)
  - [yarn](https://yarnpkg.com)
  - Recent versions of Docker & [docker-compose](https://docs.docker.com/compose/install/)

- Make sure you've set the env to indicate your choice

```bash
export WITH_DOCKER=easy
```

### Partial
The partial way consist in using bare-metal elixir and tooling, and docker-managed database & search index.

> #### Info {: .info}
>
> Note: you can use a tool like [mise](https://mise.jdx.dev/) or asdf to setup the environment (run `mise install` in the root directory).


#### Dependencies:

- Recent versions of [Elixir](https://elixir-lang.org/install.html) (1.15+) and OTP/erlang (25+)
- Recent versions of [Rust](https://www.rust-lang.org/tools/install) and Cargo
- [yarn](https://yarnpkg.com)
- Recent versions of Docker & [docker-compose](https://docs.docker.com/compose/install/)

- Make sure you've set the environment variable to indicate your choice

```bash
export WITH_DOCKER=partial
```

### No Docker

> #### Info {: .info}
>
> Note: you can use a tool like [mise](https://mise.jdx.dev/) or asdf to setup the environment (run `mise install` in the root directory). You will still need to install Postgres and Meili seperately though.

- Dependencies:
  - Recent versions of [Elixir](https://elixir-lang.org/install.html) (1.15+) and OTP/erlang (25+)
  - Recent versions of [Rust](https://www.rust-lang.org/tools/install) and Cargo
  - [yarn](https://yarnpkg.com)
  - Postgres 12+ (or rather [Postgis](https://postgis.net/install/) if using the bonfire_geolocate extension)
  - [Meili Search](https://docs.meilisearch.com/learn/getting_started/installation.html) (optional)

- If you want search capabilities, you'll also need to setup a Meili server and set the relevant env variables as well.

- Make sure you've set the environment variable to indicate your choice

```bash
export WITH_DOCKER=no
```

### The nix way 

You can also choose to use nix to setup your development environment.

#### Dependencies:

- Run a recent version of Nix or NixOS: https://nixos.org/download.html
- Enable Flakes: https://nixos.wiki/wiki/Flakes#Installing_flakes
- Install [direnv](https://direnv.net/) through nix if you don't have the tool already: `nix profile install nixpkgs#direnv` and add it to your shell: https://direnv.net/docs/hook.html
- Clone the bonfire-app repo if you haven't already and allow direnv to use environment variables:
  ```bash
  git clone https://github.com/bonfire-networks/bonfire-app
  cd `bonfire-app`
  direnv allow
  ```

The tool direnv is necessary for the nix setup as the nix shell environment will use variables defined on `.envrc` to set itself up.

Note: when you run `direnv allow` on the bonfire-app directory for the first time, nix will automatically fetch the dependencies for bonfire. The process will take a while as it's downloading everything needed to use the development environment. Afterwards you will be able to use just fine. Proceeding times you enter the directory, the shell with automatically set up for your use without downloading the packages again.

You will need to update the db directory which is automatically created by nix the first time you initialized the shell with `direnv allow`. You can do so with the following steps:
- Update `props.nix` to the settings you want.
- Run `just nix-db-init` to create the database and user for postgres defined on `props.nix`.
- Modify the `.env` file to comment out all `POSTGRES_*` variables. These are populated automatically by nix. So if the variables are set here, you may get issues with overriding your settings in `props.nix` when using bonfire.
- You can now proceed to Hello World!

Note: if you ever want to shut off the postgres server in nix, simply run the nix-db targets in just:

```
# stop postgres server running locally
just nix-db stop
# start postgres server running locally
just nix-db start
```

<!-- tabs-close -->


### Configure

Run `just config` to initialise the needed config.

```sh
just config
```

Then you can edit the config for the current flavour in `./.env`

The only required config to startup bonfire are the secrets for sessions/cookies (`SECRET_KEY_BASE`, `SIGNING_SALT`, `ENCRYPTION_SALT`), you can generate strings for these by running:

```sh
just secrets
```


## Light a fire!

From a fresh checkout of this repository, this command will fetch the app's dependencies and setup the database (the same commands apply for all three options above):

```
just setup-dev
```

This command will take a while to complete. Soon we will streamiline the setup process to be more lightway, bear with us for the moment.

You should now be able to run the app with:

```
just dev
```

Read more about the available `just` commands in the [`just` commands](./just-commands) page.

## Onboarding

### Getting Started

The back-end server runs on port 4000 (TCP) by default. Access it by navigating to http://localhost:4000/ in your web browser.

### Creating an Account

To create an account, go to http://localhost:4000/signup and enter your email address and password.
When running the server locally, you won't receive a confirmation email. However, you can find the confirmation link in the server logs.
Search for a link starting with https://localhost:4000/signup/email/confirm/ in the logs and follow the complete link to confirm your account.

### Admin Permissions

The first user registered on the platform is automatically granted Admin permissions.

### Successful Onboarding

After successfully creating and confirming your account, you should see an empty dashboard.

That's it! You have now successfully onboarded and can start using the application.

## The Bonfire Environment

We like to think of bonfire as a comfortable way of developing software - there are a lot of conveniences built in once you know how they all work. The gotcha is that while you don't know them, it can be a bit overwhelming. Don't worry, we've got your back.

- [Architecture](./ARCHITECTURE.md) - an overview of the stack and code structure.
- [Bonfire-flavoured Elixir](./BONFIRE-FLAVOURED-ELIXIR.md) - an introduction to the way we write Elixir.
- [Bonfire's Database: an Introduction](./DATABASE.md) - an overview of how our database is designed.
- [Boundaries](./BOUNDARIES.md) - an introduction to our access control system.

Note: these are still at the early draft stage, we expect to gradually improve documentation over time.

## Documentation

The code is somewhat documented inline. You can generate HTML docs (using `Exdoc`) by running `just docs`.

## Additional information

- `messctl` is a little utility for programmatically updating the .deps files from which the final elixir dependencies list is compiled by the mess script. The only use of it is in the dep-\* tasks of the Makefile. It is used by some of the project developers and the build does not rely on it.

- `./extensions/` is used to hack on local copies of Bonfire extensions. You can clone an extension from its git repo and use the local version during development, eg: `just dep-clone-local bonfire_me https://github.com/bonfire-networks/bonfire_me`

- `./forks/` is used to hack on local copies of any other dependencies.

- You can migrate the DB when the app is running (also runs automatically on startup): `Bonfire.Common.Repo.migrate`

- You can generate a dependency graph using `just xref-graph` which will generate a DOT file at `docs/` (if Graphviz is installed it will also generate an SVG visualisation using `dot`).

### Usage under Windows (WSL, MSYS or CYGWIN)

By default, the `justfile` requires symlinks, which can be enabled with the help of [this link](https://stackoverflow.com/a/59761201).

See the [pull request adding WSL support](https://github.com/bonfire-networks/bonfire-app/pull/111) for details about usage without symlinks.

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
2. Find the database configuration (search for `Bonfire.Common.Repo`).
3. Add `timeout: 60_000` to the list of options:

```
config :bonfire, Bonfire.Common.Repo,
  timeout: 60_000,
  [...]
```
