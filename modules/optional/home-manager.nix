{
  mkModule,
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
in
mkModule {
  name = "home-manager";
  path = "home-manager";
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  opts = with types; {
    version = mkOption {
      type = enum [
        "18.09"
        "19.03"
        "19.09"
        "20.03"
        "20.09"
        "21.03"
        "21.05"
        "21.11"
        "22.05"
        "22.11"
        "23.05"
        "23.11"
        "24.05"
      ];
      default = "24.05";
    };
    packages = mkOption {
      type = listOf package;
      default = with pkgs; [
        obs-studio
        youtube-music
        prismlauncher
        r2modman
        libreoffice-fresh
        pinta
      ];
    };
  };
  cfg =
    cfg:
    let
      username = config.modules.user.username;
    in
    mkIf config.modules.user.enable {
      home-manager = {
        useGlobalPkgs = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = { inherit inputs; };
        users."${username}" = {
          home = {
            inherit username;
            homeDirectory = "/home/${username}";
            stateVersion = cfg.version;

            inherit (cfg) packages;
          };

          programs.home-manager.enable = true;
        };
      };
    };
}
