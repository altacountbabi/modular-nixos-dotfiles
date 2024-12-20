{
  mkModule,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
in
mkModule {
  path = "packages";
  opts = with types; {
    extraPackages = mkOption {
      type = listOf package;
      description = "Extra packages to install";
      default = [ ];
    };
    steam = mkEnableOption "steam";
    nh = {
      enable = mkEnableOption "nh";
      flakePath = mkOption {
        type = str;
        default = "/etc/nixos";
      };
      clean = {
        enable = mkEnableOption "nh clean";
        keepSince = mkOption {
          type = str;
          default = "4d";
        };
        minGenerations = mkOption {
          type = int;
          default = 3;
        };
      };
    };
    nix-ld = {
      enable = mkEnableOption "nix-ld";
      libraries = mkOption {
        type = listOf package;
        default = [ ];
      };
    };
  };
  cfg = cfg: {
    environment.systemPackages =
      with pkgs;
      [
        # NixOS-Related Packages
        nixfmt-rfc-style
        nil

        # Cli Utilities
        libnotify # notify-send
        neofetch
        delta # better `diff`
        just # command runner
        tree
        htop
        btop
        wget
        bat # better `cat`

        # Development
        vscode
        micro
        git
        bun
      ]
      ++ cfg.extraPackages;

    programs = {
      steam.enable = cfg.steam;
      nh = mkIf cfg.nh.enable {
        enable = true;
        flake = cfg.nh.flakePath;
        clean = {
          enable = cfg.nh.clean.enable;
          extraArgs = "--keep-since ${cfg.nh.clean.keepSince} --keep ${builtins.toString cfg.nh.clean.minGenerations}";
        };
      };
      inherit (cfg) nix-ld;
    };
  };
}
