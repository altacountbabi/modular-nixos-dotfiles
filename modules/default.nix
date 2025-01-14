{
  config,
  system,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkDefault
    filesystem
    strings
    lists
    ;
  inherit (builtins) filter toString;

  mkModule = import ../lib/mkModule.nix { inherit config lib; };

  contains = list: string: builtins.any (substr: strings.hasPrefix (toString substr) string) list;

  excludedModules = [ ./optional/scripts ];
  moduleLocations = [
    ./core
    ./optional
  ];
  imports =
    map
      (
        path:
        import path {
          inherit
            mkModule
            config
            system
            inputs
            pkgs
            lib
            ;
        }
      )
      (
        filter (
          path:
          let
            fileName = baseNameOf path;
            asStr = toString path;
          in
          strings.hasSuffix ".nix" fileName && !(contains excludedModules asStr)
        ) (lists.flatten (map (path: filesystem.listFilesRecursive path) moduleLocations))
      );
in
{
  inherit imports;

  modules = mkDefault {
    # Core Modules
    boot = {
      enable = true;
      plymouth = true;
    };
    environment = {
      enable = true;
      editor = "micro";
    };
    locale = {
      enable = true;
      timeZone = "Europe/Bucharest";
      i18n.extra = "ro_RO.UTF-8";
    };
    network = {
      enable = true;
      firewall = false;
    };
    packages = {
      enable = true;
      nh = {
        enable = true;
        clean.enable = true;
      };
      nix-ld.enable = true;
    };
    user = rec {
      enable = true;
      username = "real";
      displayName = username;
    };

    # Optional Modules
    home-manager.enable = true;
    graphics.enable = true;
    flatpak.enable = true;
    services = {
      vscode-server.enable = true;
      keyd.enable = true;
      ssh.enable = true;
    };

    programming-language = {
      rust.enable = true;
    };

    editor = {
      vscode.enable = true;
      micro.enable = true;
      helix.enable = true;
    };

    colorscheme.catppuccin.enable = true;

    virt-manager.enable = true;

    desktop = {
      # Login Screen
      dm = {
        autologin.enable = true;
        gdm.enable = true;
      };

      # Desktop
      desktops.hyprland.enable = true;
      notification.mako.enable = true;
      terminal.kitty.enable = true;
      appLauncher.rofi = {
        enable = true;
        wayland =
          let
            desktops = config.modules.desktop.desktops;
          in
          # Add other compositors if needed:
          desktops.hyprland.enable; # || desktops.[other wayland compositor].enable
      };

      # Apps
      browser.zen = {
        enable = true;
        autoStart = true;
      };
      discord = {
        enable = true;
        autoStart = true;
      };
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ inputs.rust-overlay.overlays.default ];
  };
}
