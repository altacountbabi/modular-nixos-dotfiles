# Refer to https://github.com/GermanBread/declarative-flatpak/ for documentation

{
  mkModule,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "flatpak applications";
  path = "flatpak";
  imports = [ inputs.flatpaks.nixosModules.default ];
  opts = with types; {
    remotes = mkOption {
      type = attrsOf str;
      default.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
    overrides = mkOption {
      type = attrsOf (submodule {
        options = {
          filesystems = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          sockets = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          environment = mkOption {
            type = nullOr (attrsOf anything);
            default = null;
          };
        };
      });
      default.global.filesystems = [ "home" ];
    };
    packages = mkOption {
      type = listOf str;
      default = [ ":${./sober.flatpakref}" ];
    };
  };
  cfg = cfg: {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    services.flatpak = {
      enable = true;
      inherit (cfg) remotes packages overrides;
    };
  };
}
