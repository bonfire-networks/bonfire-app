{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.bonfire;
in
{
  options.services.bonfire = {
    enable = mkEnableOption "Enable Bonfire";

    port = mkOption {
      type = types.port;
      default = 4000;
      description = "port to run the instance backend on";
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

    user = mkOption {
      type = types.str;
      default = "bonfire";
      description = "User account under which pleroma runs.";
    };

    group = mkOption {
      type = types.str;
      default = "bonfire";
      description = "Group account under which pleroma runs.";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/bonfire";
      readOnly = true;
      description = "Directory where the pleroma service will save the uploads and static files.";
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

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      extraPlugins = with pkgs.postgresql_13.pkgs; [ postgis ];
      ensureDatabases = [ cfg.dbName ];
      ensureUsers = [{
        # Same name as the unix user is needed
        name = cfg.user;
        ensurePermissions = { "DATABASE ${cfg.dbName}" = "ALL PRIVILEGES"; };
      }];
    };

    users = {
      users."${cfg.user}" = {
        description = "Bonfire user";
        home = cfg.stateDir;
        group = cfg.group;
        createHome = true;
        isSystemUser = true;
      };
      groups."${cfg.group}" = { };
    };

    environment.systemPackages = [ cfg.package ];

    systemd.services.bonfire = {
      wantedBy = [ "multi-user.target" ];
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      description = "Bonfire!";
      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = 5;
        ExecStartPre = "${cfg.package}/bin/bonfire eval Bonfire.Repo.ReleaseTasks.migrate";
        ExecStart = "${cfg.package}/bin/bonfire start";
        ExecStop = "${cfg.package}/bin/bonfire stop";

        StateDirectory = "bonfire";
        WorkingDirectory = cfg.stateDir;
        StateDirectoryMode = "700";

        EnvironmentFile = cfg.environmentFile;

        PrivateTmp = true;
        PrivateHome = true;
        ProtectSystem = "full";
        NoNewPrivileges = true;

        ReadWritePaths = "${if cfg.dbSocketDir == null then "" else cfg.dbSocketDir} ${cfg.stateDir}";
      };
      environment = {
        RELEASE_TMP = "/tmp";
        TZDATA_DIR = cfg.stateDir;
        LANG = "en_US.UTF-8";
        PORT = toString cfg.port;
        POSTGRES_USER = cfg.user;
        POSTGRES_DB = cfg.dbName;
        POSTGRES_SOCKET_DIR = lib.mkIf (cfg.dbSocketDir != null) cfg.dbSocketDir;
        HOSTNAME = cfg.hostname;
        WITH_DOCKER = "no";
        FLAVOUR = "classic";
        BONFIRE_FLAVOUR = "flavours/classic";
      };
    };
  };
}
