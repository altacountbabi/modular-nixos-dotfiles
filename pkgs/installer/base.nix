{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [ ./hardware.nix ];

  modules = {
    graphics.gpuType = "GPU_TYPE";
    network.hostname = "HOSTNAME";

    disko = {
      enable = true;
      device = "DISKO_DEVICE";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?
}
