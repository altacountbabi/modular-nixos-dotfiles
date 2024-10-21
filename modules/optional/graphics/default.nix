{ mkModule, lib, ... }:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "graphics";
  path = "graphics";
  opts = with types; {
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
      enable = true;
      inherit (cfg) xkb;
    };
  };
}
