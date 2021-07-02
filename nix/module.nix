{ pkgs, config, lib, ... }:
with lib;
let
  bonfireConfig = config.services.bonfire;
in
{
  options.services.bonfire = {
    port = mkOption {
      type = types.port;
      default = 4000;
      description = "port to run the instance on";
    };
    package = mkOption {
      type = types.package;
      description = "package to run the instance with";
    };
    hostname = mkOption {
      type = types.str;
      default = "bonfire.cafe";
      example = "bonfire.cafe";
      description = ''
        hostname for which the service will be run
      '';
    };
    dbName = mkOption {
      type = types.str;
      default = "bonfire";
      description = ''
        name of the database you want to connect to
      '';
    };
    dbSocketDir = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If this is defined, bonfire will connect to postgres
        with a unix socket and not TCP/IP
      '';
    };
    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        environment file for secret environment variables
        should contain
        SECRET_KEY_BASE
        SIGNING_SALT
        ENCRYPTION_SALT
        RELEASE_COOKIE
      '';
    };
  };

  config = with bonfireConfig; {
    services.postgresql = {
      extraPlugins = with pkgs.postgresql_13.pkgs; [ postgis ];
      ensureDatabases = [ dbName ];
      ensureUsers = [{
        # Same name as the unix user is needed
        name = "bonfire";
        ensurePermissions = { "DATABASE ${dbName}" = "ALL PRIVILEGES"; };
      }];
    };

    systemd.services.bonfire = {
      wantedBy = [ "multi-user.target" ];
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      description = "Bonfire!";
      serviceConfig = {
        Type = "exec";
        Restart = "on-failure";
        RestartSec = 5;
        ExecStartPre = "${package}/bin/bonfire eval Bonfire.Repo.ReleaseTasks.migrate";
        ExecStart = "${package}/bin/bonfire start";
        ExecStop = "${package}/bin/bonfire stop";

        DynamicUser = true;
        StateDirectory = "bonfire";

        EnvironmentFile = environmentFile;

        PrivateTmp = true;
        ProtectSystem = "full";
        NoNewPrivileges = true;

        ReadWritePaths = "${if dbSocketDir == null then "" else dbSocketDir} /var/lib/bonfire";
      };
      environment = {
        RELEASE_TMP = "/tmp";
        TZDATA_DIR = "/var/lib/bonfire";
        LANG = "en_US.UTF-8";
        PORT = toString port;
        POSTGRES_USER = "bonfire";
        POSTGRES_DB = dbName;
        POSTGRES_SOCKET_DIR = lib.mkIf (dbSocketDir != null) dbSocketDir;
        HOSTNAME = hostname;
        WITH_DOCKER = "no";
        FLAVOUR = "coordination";
        BONFIRE_FLAVOUR = "flavours/coordination";
      };
    };
  };
}
