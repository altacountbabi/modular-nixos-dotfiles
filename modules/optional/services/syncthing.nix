{
  mkModule,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "syncthing";
  path = "services.syncthing";
  opts = with types; {
    devices = mkOption {
      type = anything;
      default = { };
    };
    folders = mkOption {
      type = anything;
      default = { };
    };
  };
  cfg = cfg: {
    services.syncthing =
      let
        user = config.modules.user.username;
      in
      {
        enable = true;
        openDefaultPorts = true;
        inherit user;
        dataDir = "/home/${user}";
        settings = {
          inherit (cfg) devices folders;
        };
      };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
  };
}
