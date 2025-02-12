{ pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  modules = {
    graphics.gpuType = "nvidia";
    network.hostname = "laptop-nixos";
    services.tailscale.enable = true;

    packages.steam = false;

    virt-manager.enable = false;

    services = {
      mediaServer.enable = true;
      docker.enable = true;
      ftp.enable = true;
    };

    desktop = {
      browser.zen.autoStart = false;
      discord.autoStart = false;
    };

    home-manager.packages = with pkgs; [ pavucontrol ];
  };

  # Disable lid switch
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
