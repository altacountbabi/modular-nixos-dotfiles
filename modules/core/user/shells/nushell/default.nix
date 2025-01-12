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
  name = "nushell";
  path = "shells.nushell";
  opts = with types; {
    enable = mkOption {
      type = bool;
      default = config.modules.user.shell == pkgs.nushell;
    };
  };
  hm = cfg: {
    programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      envFile.source = ./env.nu;
    };
  };
}
