{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) elem;
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
  hm =
    cfg:
    let
      mkOptAlias =
        from: to: package:
        if elem package config.environment.systemPackages then { "${from}" = "${to}"; } else { };
    in
    {
      programs.nushell = {
        enable = true;
        configFile.source = ./config.nu;
        envFile.source = ./env.nu;
      };
    };
}
