{
  inputs,
  system,
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
    services = {
      tailscale.enable = true;
      syncthing.enable = true;
      openrazer.enable = true;
    };

    editor.helix.latest = true;

    home-manager.packages = with pkgs; [
      figma-linux
      processing
      localsend
      obsidian
      ghidra
    ];

    flatpak.packages = [
      ":${../../modules/optional/flatpak/sober.flatpakref}"
      # Screen sharing on wayland doesnt work with zoom from nixpkgs
      "flathub:app/us.zoom.Zoom/x86_64/stable"
    ];

    desktop = {
      desktops.hyprland.monitor = [
        ",1920x1080@240,0x0,1,vrr,0"
      ];
      desktops.niri.outputs = {
        "DP-1".mode = {
          height = 1080;
          width = 1920;
          refresh = 240.0;
        };
      };
      desktops.niri.enable = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
