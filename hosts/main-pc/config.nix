{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  modules = {
    graphics.gpuType = "amd";
    network.hostname = "main-pc";
    services.tailscale.enable = true;

    editor.helix.latest = true;

    home-manager.packages = with pkgs; [
      localsend
      obsidian
      figma-linux
      devenv
    ];

    desktop.desktops.hyprland.monitor = [
      ",1920x1080@240,0x0,1,vrr,2"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
