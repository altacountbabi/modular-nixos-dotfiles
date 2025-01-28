{
  mkModule,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption;
in
mkModule {
  name = "eww";
  path = "desktop.eww";
  opts = {
    bar = mkEnableOption "Bar UI";
  };
  hm = cfg: {
    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };
}
