{
  description = "Bonfire self contained build";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      # props to hold settings to apply on this file like name and version
      props = import ./props.nix;
      # set elixir nix version
      elixir_nix_version = elixir_version:
        builtins.replaceStrings [ "." ] [ "_" ] "elixir_${elixir_version}";
      erlang_nix_version = erlang_version: "erlangR${erlang_version}";
    in
    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems
      (system:
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

          # This is setting locality to latin for some reason
          locality = pkgs.glibcLocales;

          # Install hook for mixRelease 
          installHook = ''
            export APP_VERSION="${version}"
            export APP_NAME="${pname}"
            export ELIXIR_RELEASE="${props.elixir_release}"
            runHook preInstall
            mix release --no-deps-check --path "$out"
            runHook postInstall
          '';

          # Pass just as a build input 
          inputsBuild = with pkgs; [ just ];

          # Had to change the find command because it wasn't working
          fetchMixInstallPhase = { mixEnv }: ''
            runHook preInstall
            mix deps.get --only ${mixEnv}
            find "$TEMPDIR/deps" -path '*/.git/*' -a ! -name HEAD -prune -execdir rm -rf {} + 
            cp -r --no-preserve=mode,ownership,timestamps $TEMPDIR/deps $out
            runHook postInstall
          '';

          # Run just before compiling to set up the environment
          configureHook = ''
            runHook preConfigure
            ${./mix-configure-hook.sh}

            # Run just and setup config directory before we compile 
            # TODO allow choosing flavor
            just rel-init
            just rel-prepare
            just assets-prepare
            cp -r data/current_flavour/config/ ./config/

            # this is needed for projects that have a specific compile step
            # the dependency needs to be compiled in order for the task
            # to be available
            # Phoenix projects for example will need compile.phoenix
            mix do deps.compile --no-deps-check --skip-umbrella-children 

            runHook postConfigure
          '';

          # src of the project
          src = ./.;

          mixFodDeps = beamPackages.fetchMixDeps {
            pname = "mix-deps-${pname}";
            inherit src version;
            installPhase = fetchMixInstallPhase { mixEnv = "prod"; };
            # nix will complain and tell you the right value to replace this with
            sha256 = "7MGvdRnrzrfCBX8c/nScHrTzmaaWKzre4buQzw0gYGE=";
          };

          # mix release definition
          release-prod = beamPackages.mixRelease {
            inherit src pname version mixFodDeps elixir;
            configurePhase = configureHook;
            buildInputs = inputsBuild;

            installPhase = installHook;
          };
        in
        rec {
          # packages to build
          packages = {
            prod = release-prod;

            default = packages.prod;
          };

          # apps to run with nix run
          apps = {
            prod = flake-utils.lib.mkApp {
              name = pname;
              drv = packages.prod;
              exePath = "/bin/prod";
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
              export PGHOST=$PWD/db
              export PGUSERNAME=${props.PGUSERNAME}
              export PGPASS=${props.PGPASS}
              export PGDATABASE=${props.PGDATABASE}
              export POSTGRES_USER=${props.PGUSERNAME}
              export POSTGRES_PASSWORD=${props.PGPASS}
              export POSTGRES_DB=${props.PGDATABASE}
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
              locality
              rebar3
              rebar
              pkgs.yarn
              pkgs.cargo
              pkgs.rustc
              (pkgs.postgresql_12.withPackages (p: [ p.postgis ]))
            ] ++ optional pkgs.stdenv.isLinux
              pkgs.libnotify # For ExUnit Notifier on Linux.
            ++ optional pkgs.stdenv.isLinux
              pkgs.meilisearch # For meilisearch when running linux only
            ++ optional pkgs.stdenv.isLinux
              pkgs.inotify-tools; # For file_system on Linux.
          };
        }) // {
      # Module for deployment
      # Doesn't get built per system
      nixosModules.bonfire = import ./nix/module.nix;
      nixosModule = self.nixosModules.bonfire;
    };
}
