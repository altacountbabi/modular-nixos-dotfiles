{
  mkModule,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "amd gpu drivers";
  path = "gpu.amd";
  opts = with types; {
    enable = mkOption {
      type = bool;
      default = config.modules.graphics.gpuType == "amd";
    };
  };
  cfg = cfg: {
    hardware.graphics.enable = true;
  };
}
