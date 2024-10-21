{
  mkModule,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkOption mkEnableOption types;
in
mkModule {
  name = "network management";
  path = "network";
  opts = with types; {
    firewall = mkEnableOption "firewall";
    hostname = mkOption {
      type = str;
      default = "nixos";
    };
  };
  cfg = cfg: {
    networking = {
      networkmanager.enable = !config.networking.wireless.enable;
      firewall.enable = cfg.firewall;
      hostName = cfg.hostname;
    };
  };
}
