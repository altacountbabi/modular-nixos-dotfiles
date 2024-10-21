{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) elem;
  inherit (lib) mkOption types;
in
mkModule {
  name = "zsh";
  path = "shells.zsh";
  opts = with types; {
    enable = mkOption {
      type = bool;
      default = config.modules.user.shell == pkgs.zsh;
    };
  };
  cfg =
    cfg:
    let
      mkOptAlias =
        from: to: package:
        if elem package config.environment.systemPackages then { "${from}" = "${to}"; } else { };
    in
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;

        shellInit = ''
          # Maybe one day we will have aliases with spaces so that I dont have to do this garbage.
          nix() {
            if [ "$1" = "search" ]; then
              shift
              ${pkgs.nix-search-cli}/bin/nix-search "$@"
            else
              command nix "$@"
            fi
          }
        '';
        shellAliases =
          with pkgs;
          {
            mkcd = "function mkcd() { mkdir -p \"\$1\" && cd \"\$1\" }; mkcd";
            ns = "nix-shell -p --command 'zsh'";
            mkexec = "chmod +x";
            q = "exit";
          }
          // (mkOptAlias "diff" "delta" delta)
          // (mkOptAlias "hexec" "hyprctl dispatch exec" hyprland)
          // (mkOptAlias "cat" "bat" bat);

        promptInit = ''
          PROMPT="%~"$'\n'"❯%f "
        '';
      };
    };
}
