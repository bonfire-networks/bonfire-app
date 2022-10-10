{
  description = "Bonfire self contained build";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      # props to hold settings to apply on this file like name and version
      props = import ./nix/props.nix;
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
            # This might not be necessary for FOD builds
            ${./nix/mix-configure-hook.sh}

            # Run just and setup config directory before we compile 
            # TODO allow choosing flavor
            APP_BUILD=none just rel-init
            APP_BUILD=none just rel-prepare 
            APP_BUILD=none just assets-prepare 
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
            # nix will complain and tell you the right value to replace this with if deps change
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
              pkgs.just
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
        }) //
    {
      # Module for deployment
      # Doesn't get built per system
      nixosModules.bonfire = import ./nix/module.nix;
      nixosModule = self.nixosModules.bonfire;

      # Test container to make sure the module / package work
      # If you're using nixOS you can run this with: 
      # `sudo nixos-container create <name> --flake .#test`  # will take a while, because it builds bonfire
      # `sudo nixos-container start <name>` 
      # You should then be able to view bonfire at http://<ip>
      # You can get ip from `sudo nixos-container show-ip <name>`
      nixosConfigurations."test" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModule
          ({ pkgs, ... }: {
            boot.isContainer = true;
            networking.hostName = "bonfire-test";
            system.stateVersion = "22.05";
            networking.firewall.allowedTCPPorts = [ 80 ];
            environment.etc."bonfire-test-secrets".text = ''
              # These are random test values
              # DO NOT USE THIS IN YOUR CONFIGURATION 
              SECRET_KEY_BASE=RjGsaxeysELzFf4fmCzZTxYmqWmwroLbMQ/5d2oyfOGdkvdkSSkOm2EFPdPD2Mgu4JrVIQNy/1QD9+UQrCEnsmVUvaw86jc8RMHRkSn5NHqKkiPifuVIS4w/BJRnASNP
              SIGNING_SALT=IlUkRlK33+QV0B5tuY3P1X8mMamoruBrEd3mtGPKiGO70/t/rmIdCZdc7vLu1Q8VBzADqZ5pSOk+L78qg9i0IK9fJ1zbFeSFpyLGKdvny/S7S2uNb4a+5yYVxLbtOIQs
              ENCRYPTION_SALT=58fau1M/b4tl58iMs7rBwcw/CQ4ZcazqF/JLRmYEvkf9xBNcdusOYzVuvk12q5iZQPBnI+6AY1vY2OEpyZ7rYa6AClW6hyO2axZwoPyluwCiv6QShGtgSTOl56D2dBTf
              RELEASE_COOKIE=vpP1kluF2F4W3q1L1Exulkfu7C5UQhuO
            '';
            services.postgresql.enable = true;
            services.bonfire = {
              enable = true;
              hostname = "test.bonfire.lan";
              port = 80;
              package = self.packages.x86_64-linux.default;
              environmentFile = "/etc/bonfire-test-secrets";
            };
          })
        ];
      };

    };
}
