{ pkgs, flavour ? "cooperation" }:

with pkgs;

let
  messctl = rustPlatform.buildRustPackage rec {
    pname = "messctl";
    version = "0.0.1";

    src = fetchFromGitHub {
      owner = "bonfire-networks";
      repo = pname;
      rev = "8421d5ee91b120f1fe78fe8b123fc0fdf59609ff";
      sha256 = "sha256-MniXkng8v30xzSC+cIZ+K6DWeJLCFDieXZioAQFU4/s=";
    };
    cargoSha256 = "sha256-K4Wq949DK3STwKo0MgaGNsu3r+qg8OqqXK3O4g4FpR0=";
  };

  # define packages to install with special handling for OSX
  shellBasePackages = [
    git
    beam.packages.erlang.elixir_1_12
    nodejs-16_x
    nodePackages.pnpm
    postgresql_13
    messctl
    # for NIFs
    rustfmt
    clippy
  ];

  shellBuildInputs = shellBasePackages ++ lib.optional stdenv.isLinux inotify-tools
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  # define shell startup command
  shellHooks = ''
    # this allows mix to work on the local directory
    mkdir -p $PWD/.nix-mix
    mkdir -p $PWD/.nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-mix
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    mix local.hex --force
    export LANG=en_US.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"

    # postges related
    export PGDATA="$PWD/db"

    # elixir
    export MIX_ENV=dev
    export FORKS_PATH=./forks

    # bonfire
    export FLAVOUR=${flavour}
    export BONFIRE_FLAVOUR=flavours/${flavour}
    export WITH_DOCKER=no
  '';

in

mkShell
{
  nativeBuildInputs = [ rustc cargo gcc ]; # for NIFs
  buildInputs = shellBuildInputs;
  shellHook = shellHooks;
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}

