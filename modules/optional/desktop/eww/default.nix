{
  mkModule,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
mkModule {
  name = "eww";
  path = "desktop.eww";
  hm = cfg: {
    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };
}
