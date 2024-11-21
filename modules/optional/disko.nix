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
  imports = [ inputs.disko.nixosModules.default ];
  opts.device = mkOption {
    type = types.str;
    example = "'/dev/sda' or '/dev/disk/by-id/some-disk-id'";
  };
  cfg = cfg: {
    disko.devices.disk.main = {
      inherit (cfg) device;
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
}
