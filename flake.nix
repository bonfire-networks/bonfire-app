{
  description = "Bonfire self contained build";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      # props to hold settings to apply on this file like name and version
      props = import ./props.nix;
      # set elixir nix version
      elixir_nix_version = elixir_version:
        builtins.replaceStrings [ "." ] [ "_" ] "elixir_${elixir_version}";
      erlang_nix_version = erlang_version: "erlangR${erlang_version}";
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        inherit (nixpkgs.lib) optional;
        pkgs = import nixpkgs { inherit system; };

        # project name for mix release
        pname = props.app_name;
        # project version for mix release
        version = props.app_version;

        # use ~r/erlangR[1-9]+/ for specific erlang release version
        beamPackages = pkgs.beam.packagesWith
          pkgs.beam.interpreters.${erlang_nix_version props.erlang_release};
        # all elixir and erlange packages
        erlang = beamPackages.erlang;
        # use ~r/elixir_1_[1-9]+/ major elixir version
        elixir = beamPackages.${elixir_nix_version props.elixir_release};
        elixir-ls = beamPackages.elixir_ls.overrideAttrs
          (oldAttrs: rec { elixir = elixir; });
        hex = beamPackages.hex;

        # use rebar from nix instead of fetch externally
        rebar3 = beamPackages.rebar3;
        rebar = beamPackages.rebar;

        locality = pkgs.glibcLocales;

        # needed to set libs for mix2nix
        lib = pkgs.lib;
        mix2nix = pkgs.mix2nix;

        installHook = { release }: ''
          export APP_VERSION="${version}"
          export APP_NAME="${pname}"
          export ELIXIR_RELEASE="${props.elixir_release}"
          runHook preInstall
          mix release --no-deps-check --path "$out" ${release}
          runHook postInstall
        '';

        # src of the project
        src = ./.;
        # mix2nix dependencies
        mixNixDeps = import ./deps.nix { inherit lib beamPackages; };

        # mix release definition
        release-prod = beamPackages.mixRelease {
          inherit src pname version mixNixDeps elixir;
          mixEnv = "prod";

          installPhase = installHook { release = "prod"; };
        };

        release-dev = beamPackages.mixRelease {
          inherit src pname version mixNixDeps elixir;
          mixEnv = "dev";
          enableDebugInfo = true;
          installPhase = installHook { release = "dev"; };
        };
      in rec {
        # packages to build
        packages = {
          prod = release-prod;
          dev = release-dev;
          container = pkgs.dockerTools.buildImage {
            name = pname;
            tag = packages.prod.version;
            # required extra packages to make release work
            contents =
              [ packages.prod pkgs.coreutils pkgs.gnused pkgs.gnugrep ];
            created = "now";
            config.Entrypoint = [ "${packages.prod}/bin/prod" ];
            config.Cmd = [ "version" ];
          };
          oci = pkgs.ociTools.buildContainer {
            args = [ "${packages.prod}/bin/prod" ];
          };
          default = packages.prod;
        };

        # apps to run with nix run
        apps = {
          prod = flake-utils.lib.mkApp {
            name = pname;
            drv = packages.prod;
            exePath = "/bin/prod";
          };
          dev = flake-utils.lib.mkApp {
            name = "${pname}-dev";
            drv = packages.dev;
            exePath = "/bin/dev";
          };
          default = apps.prod;
        };

        devShells.default = pkgs.mkShell {

          shellHook = ''
            export APP_VERSION="${version}"
            export APP_NAME="${pname}"
            export ELIXIR_MAJOR_RELEASE="${props.elixir_release}"
            export MIX_HOME="$PWD/.cache/mix";
            export HEX_HOME="$PWD/.cache/hex";
            export MIX_PATH="${hex}/lib/erlang/lib/hex/ebin"
            export PATH="$MIX_PATH/bin:$HEX_HOME/bin:$PATH"
            mix local.rebar --if-missing rebar3 ${rebar3}/bin/rebar3;
            mix local.rebar --if-missing rebar ${rebar}/bin/rebar;

            export PGDATA=$PWD/db
            export PGHOST=$PGDATA
            export PGUSERNAME=$POSTGRES_USER
            export PGPASS=$POSTGRES_PASSWORD
            export PGDATABASE=$POSTGRES_DB
            if [[ ! -d $PGDATA ]]; then
              mkdir $PGDATA
              # comment out if not using CoW fs
              chattr +C $PGDATA
              initdb -D $PGDATA
            fi
          '';

          buildInputs = [
            elixir
            erlang
            mix2nix
            locality
            rebar3
            rebar
            pkgs.yarn
            pkgs.cargo
            pkgs.rustc
            pkgs.postgis
            pkgs.postgresql
            pkgs.meilisearch
          ] ++ optional pkgs.stdenv.isLinux
            pkgs.libnotify # For ExUnit Notifier on Linux.
            ++ optional pkgs.stdenv.isLinux
            pkgs.inotify-tools; # For file_system on Linux.
        };
      });
}
