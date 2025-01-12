{ pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  modules = {
    # System settings
    graphics.gpuType = "nvidia";
    network.hostname = "luke";

    user = rec {
      username = "orang";
      displayName = username;
    };

    services = {
      vscode-server.enable = false;
      keyd.enable = false;
      ssh.enable = false;
    };

    locale = {
      timeZone = "EST";
      i18n.extra = "en_US.UTF-8";
    };

    packages = {
      extraPackages = with pkgs; [ wineWowPackages.stable ];
      steam = true;
    };

    # Desktop settings
    desktop = {
      dm.autologin.enable = false;

      browser = {
        zen.enable = false;
        firefox.enable = true;
      };
      discord.autoStart = false;
    };

    # Add extra packages here not in home-manager.nix
    home-manager.packages = with pkgs; [
      thunderbird
      r2modman
      protonvpn-gui
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?
}
