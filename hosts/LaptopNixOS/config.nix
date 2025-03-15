{
  inputs,
  system,
  pkgs,
  ...
}:

{
  imports = [ ./hardware.nix ];

  modules = {
    # System settings
    boot = {
      bootloader.timeout = 5; # Timeout before it proceeds with the selected boot option
      plymouth = false; # Disable boot splash
    };
    graphics.gpuType = "nvidia";
    network.hostname = "LaptopNixOS";

    user = rec {
      username = "sablesk";
      displayName = username;
    };

    locale = {
      timeZone = "EST";
      i18n.extra = "en_US.UTF-8";
    };

    # Desktop settings
    desktop = {
      dm.autologin.enable = false;
      eww.bar = true;

      desktops.hyprland.batteryInfo = true;

      libreoffice.normalTheme = true;

      browser.zen = {
        autoStart = false;
        package = inputs.zen-browser-new.packages."${system}".twilight;
      };
      discord.autoStart = false;
    };

    # Add extra packages here not in home-manager.nix
    home-manager.packages = with pkgs; [
      protonvpn-gui
      thunderbird
      floorp
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
