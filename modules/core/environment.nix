{ mkModule, lib, ... }:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "environment variables";
  path = "environment";
  opts = with types; {
    editor = mkOption { type = str; };
  };
  cfg = cfg: {
    environment.sessionVariables = {
      EDITOR = cfg.editor;
      MICRO_TRUECOLOR = 1;
      NIXOS_OZONE_WL = "1";
    };
  };
}
