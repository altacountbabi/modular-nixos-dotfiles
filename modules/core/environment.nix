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
      # Fix audio crackling/popping in some games
      PULSE_LATENCY_MSEC = 50;
    };
  };
}
