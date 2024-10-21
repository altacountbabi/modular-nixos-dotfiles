{
  config,
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
  inherit (builtins) elem filter toString;

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
    user = {
      enable = true;
      username = "real";
      displayName = "Real Moment";
      shell = pkgs.zsh;
    };

    # Optional Modules
    sops.enable = true;
    flatpak.enable = true;
    graphics.enable = true;
    services = {
      keyd.enable = true;
      ssh.enable = true;
      vscode-server.enable = true;
    };

    desktops.hyprland.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;
}
