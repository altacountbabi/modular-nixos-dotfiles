# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to config.nix instead.
{
  config,
  lib,
  system,
  modulesPath,
  ...
}:

let
  inherit (lib) mkDefault;
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ccf4e43e-ea6f-403b-8d3d-4b04691fd361";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/40EA-6A4E";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/2a6f49bd-8b8a-4cd5-a486-38cb64141e52"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = mkDefault true;
  # networking.interfaces.enp60s0.useDHCP = mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = mkDefault true;

  nixpkgs.hostPlatform = mkDefault system;
  hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
}
