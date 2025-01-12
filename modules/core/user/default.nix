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
  name = "user management";
  path = "user";
  opts = with types; {
    username = mkOption { type = str; };
    displayName = mkOption { type = str; };
    shell = mkOption {
      type = package;
      default = pkgs.nushell;
    };
    extraGroups = mkOption {
      type = listOf str;
      default = [ ];
    };
  };
  cfg = cfg: {
    users.users = {
      root.shell = cfg.shell;
      "${cfg.username}" = {
        shell = cfg.shell;
        isNormalUser = true;
        description = cfg.displayName;
        extraGroups =
          cfg.extraGroups
          ++ (if config.modules.network.enable then [ "networkmanager" ] else [ ])
          ++ [ "wheel" ];
      };
    };
  };
}
