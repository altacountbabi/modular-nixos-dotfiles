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
  name = "jellyfin";
  path = "services.jellyfin";
  opts = with types; {
    dataDir = mkOption {
      type = str;
      default = "/home/${user}/jellyfin";
    };
  };
  cfg = cfg: {
    services.jellyfin = {
      enable = true;
      inherit user;
      dataDir = "${cfg.dataDir}/data";
      cacheDir = "${cfg.dataDir}/cache";
      openFirewall = true;
    };
  };
}
