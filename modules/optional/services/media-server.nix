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
    services = {
      jellyfin = {
        enable = true;
        inherit user;
        dataDir = "${cfg.dataDir}/data";
        cacheDir = "${cfg.dataDir}/cache";
        openFirewall = true;

        jellyseer.enable = true;
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
        settings = {
          download-dir = "${cfg.dataDir}/movies";
          rpc-bind-address = "0.0.0.0";
          rpc-enabled = true;
          rpc-port = 9091;
        };
      };
    };
  };
}
