{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    mkEnableOption
    types
    ;
in
mkModule {
  name = "network management";
  path = "network";
  opts = with types; {
    wol = {
      enable = mkEnableOption "WOL (Wake On Lan)";
      interface = mkOption {
        type = str;
        default = "eth0";
      };
    };
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

    systemd.services.enable-wol = mkIf cfg.wol.enable {
      description = "Enable Wake-on-LAN";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = [ "${pkgs.ethtool}/bin/ethtool -s ${cfg.wol.interface} wol g" ];
      };
    };
  };
}
