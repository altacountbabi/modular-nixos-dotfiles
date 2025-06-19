{
  mkModule,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption mkEnableOption types;
in
mkModule {
  name = "boot settings";
  path = "boot";
  opts = with types; {
    bootloader.timeout = mkOption {
      type = int;
      default = 0;
    };
    plymouth = mkEnableOption "plymouth";
  };
  cfg = cfg: {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = cfg.bootloader.timeout;
      };

      kernelPackages = pkgs.linuxPackages_latest;

      plymouth.enable = cfg.plymouth;

      consoleLogLevel = (if cfg.plymouth then 0 else 4);
      initrd.verbose = !cfg.plymouth;
      kernelParams =
        [
          "loglevel=3"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
        ]
        ++ (
          if cfg.plymouth then
            [
              "quiet"
              "splash"
              "rd.systemd.show_status=false"
            ]
          else
            [ ]
        );
    };
  };
}
