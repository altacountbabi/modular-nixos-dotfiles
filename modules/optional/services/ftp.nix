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
  name = "ftp via vsftpd";
  path = "services.ftp";
  opts = with types; {
    allowWrite = mkOption {
      type = bool;
      default = true;
    };
  };
  cfg = cfg: {
    services.vsftpd = {
      enable = true;
      userlist = [ config.modules.user.username ];
      writeEnable = cfg.allowWrite;
      anonymousUploadEnable = true;
      anonymousMkdirEnable = true;
      allowWriteableChroot = true;
      chrootlocalUser = true;
      localUsers = true;
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
