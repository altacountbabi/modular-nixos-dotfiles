{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

mkModule {
  name = "environment variables";
  path = "environment";
  cfg = cfg: {
    environment.sessionVariables = {
      MICRO_TRUECOLOR = 1;
      ${if config.modules.graphics.gpuType != "nvidia" then "NIXOS_OZONE_WL" else null} = "1";
      # Fix audio crackling/popping in some games
      PULSE_LATENCY_MSEC = 50;
      # Include common libraries in the ld library path
      LD_LIBRARY_PATH =
        let
          libs = with pkgs; [
            stdenv.cc.cc.lib
            libglvnd
            libGL
          ];
        in
        builtins.toString (lib.makeLibraryPath libs);
      ${if config.modules.editor.helix.enable then "EDITOR" else null} = "hx";
    };
  };
}
