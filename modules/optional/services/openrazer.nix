{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "openrazer";
  path = "services.openrazer";
  opts = with types; {
    frontend = mkOption {
      type = package;
      default = pkgs.polychromatic;
    };
  };
  cfg = cfg: {
    hardware.openrazer = {
      enable = true;
      users = [ config.modules.user.username ];
    };

    environment.systemPackages = with pkgs; [
      openrazer-daemon
      cfg.frontend
    ];
  };
}
