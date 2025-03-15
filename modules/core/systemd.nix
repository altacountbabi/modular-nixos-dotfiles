{
  mkModule,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "systemd";
  path = "systemd";
  opts = with types; {
    timeoutStopSec = mkOption {
      type = str;
      default = "10s";
    };
  };
  cfg = cfg: {
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=${cfg.timeoutStopSec}
    '';
  };
}
