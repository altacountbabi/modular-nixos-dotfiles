{
  mkModule,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
  user = config.modules.user.username;
in
mkModule {
  name = "media server";
  path = "services.mediaServer";
  opts = with types; {
    dataDir = mkOption {
      type = str;
      default = "/home/${user}/jellyfin";
    };
  };
  cfg = cfg: {
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        jellyseerr = {
          image = "fallenbagel/jellyseerr:latest";
          ports = [ "5055:5055" ];
          environment = {
            LOG_LEVEL = "debug";
            TZ = config.modules.locale.timeZone;
          };
          volumes = [
            "${cfg.dataDir}/jellyseerr:/app/config"
          ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      5055 # jellyseerr
    ];

    services = {
      jellyfin = {
        enable = true;
        inherit user;
        dataDir = "${cfg.dataDir}/data";
        cacheDir = "${cfg.dataDir}/cache";
        openFirewall = true;
      };

      # I would download a car
      radarr = {
        enable = true;
        openFirewall = true;
        inherit user;
      };

      # Indexer for radarr
      prowlarr = {
        enable = true;
        openFirewall = true;
      };

      # Download client used by radarr
      transmission = {
        enable = true; # Enable transmission daemon
        openRPCPort = true; # Open firewall for RPC
        inherit user;
        settings = {
          download-dir = "${cfg.dataDir}/transmissionDL";
          rpc-whitelist-enabled = false;
          rpc-bind-address = "0.0.0.0";
          rpc-enabled = true;
          rpc-port = 9091;
        };
      };
    };
  };
}
