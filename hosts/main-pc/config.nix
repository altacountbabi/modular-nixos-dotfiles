{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # 16GB
    }
  ];

  virtualisation.waydroid.enable = true;

  services.printing = {
    enable = true;
  };

  modules = {
    graphics.gpuType = "amd";
    network = {
      hostname = "main-pc";
      wol = {
        enable = true;
        interface = "enp4s0";
      };
    };
    services = {
      tailscale.enable = true;
      syncthing.enable = true;
      openrazer.enable = false;
      docker.enable = true;
    };

    programming-language.android.enable = true;

    editor.helix.package = import ../../pkgs/helix { inherit pkgs; };

    home-manager.packages =
      let
        gamescope-amdvlk = import ../../pkgs/gamescope {
          inherit pkgs;
          amd = config.modules.graphics.gpuType == "amd";
        };
      in
      with pkgs;
      [
        gamescope-amdvlk
        figma-linux
        processing
        localsend
        obsidian
        amberol
        eartag
        ghidra
        gimp3
      ];

    flatpak.packages = [
      ":${../../modules/optional/flatpak/sober.flatpakref}"
      # Screen sharing on wayland doesnt work with zoom from nixpkgs
      "flathub:app/us.zoom.Zoom/x86_64/stable"
      "flathub:app/re.sonny.Workbench/x86_64/stable"
      "flathub:app/org.gnome.design.IconLibrary/x86_64/stable"
    ];

    desktop = {
      desktops.hyprland.monitor = [
        ",1920x1080@240,0x0,1,vrr,0"
        # ",2560x1440@240, 0x0, 1, vrr,0, bitdepth,10, cm,hdr"
      ];
      desktops.niri = {
        enable = true;
        outputs = {
          "DP-1".mode = {
            width = 1920;
            height = 1080;
            refresh = 240.0;
          };
          # "DP-1".mode = {
          #   width = 2560;
          #   height = 1440;
          #   refresh = 359.979;
          # };
        };
      };
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
