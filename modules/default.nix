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
  getScript = import ../lib/getScript.nix { inherit config pkgs lib; };
  match = import ../lib/mkModule.nix;

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
            getScript
            mkModule
            config
            system
            inputs
            match
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
    systemd.enable = true;
    environment.enable = true;
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
    yazi.enable = true;

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
      eww.enable = true;

      # Apps
      browser.zen = {
        enable = true;
        autoStart = true;
      };
      discord = {
        enable = true;
        autoStart = true;
      };
      libreoffice.enable = true;
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@users"
    ];
    warn-dirty = false;
    lazy-trees = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "dotnet-sdk-6.0.428"
        "aspnetcore-runtime-6.0.36"
      ];
    };
    overlays = [
      inputs.rust-overlay.overlays.default
      inputs.nuenv.overlays.default
      inputs.niri.overlays.niri
    ];
  };
}
