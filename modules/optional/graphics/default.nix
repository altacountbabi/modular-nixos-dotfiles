{ mkModule, lib, ... }:

let
  inherit (lib) mkOption mkEnableOption types;
in
mkModule {
  name = "graphics";
  path = "graphics";
  opts = with types; {
    enableX = mkEnableOption "Enable X server";
    xkb = {
      layout = mkOption {
        type = str;
        default = "us";
      };
      variant = mkOption {
        type = str;
        default = "";
      };
      options = mkOption {
        type = str;
        default = "";
      };
    };
    gpuType = mkOption {
      type = enum [
        "amd"
        "nvidia"
        "none"
      ];
      description = "What gpu driver to use";
      example = ''"nvidia" or "amd"'';
      default = "none";
    };
  };
  cfg = cfg: {
    hardware.graphics.enable = true;
    services.xserver = {
      enable = cfg.enableX;
      inherit (cfg) xkb;
    };
  };
}
