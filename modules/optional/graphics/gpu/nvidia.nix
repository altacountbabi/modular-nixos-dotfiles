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
  name = "nvidia gpu drivers";
  path = "gpu.nvidia";
  opts = with types; {
    enable = mkOption {
      type = bool;
      default = config.modules.graphics.gpuType == "nvidia";
    };
  };
  cfg = cfg: {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware = {
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.production;
        modesetting.enable = true;
        open = true;
      };
      graphics.enable = true;
    };
  };
}
