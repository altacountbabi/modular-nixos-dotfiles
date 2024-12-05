{
  mkModule,
  inputs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "disko";
  path = "disko";
  imports = [ inputs.disko.nixosModules.disko ];
  opts = with types; rec {
    device = mkOption {
      type = str;
      example = "/dev/sda or /dev/nvme0n1";
    };
    devices = mkOption {
      # im not writing types for allat
      type = any;
      default = {
        disk.main = {
          inherit device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "500M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
  cfg = cfg: {
    disko.devices = cfg.devices;
  };
}
