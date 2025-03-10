{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
mkModule {
  name = "rofi";
  path = "desktop.appLauncher.rofi";
  opts = {
    wayland = mkEnableOption "wayland support";
  };
  hm =
    cfg:
    let
      rofi-emoji-better = import ../../../../pkgs/rofi-emoji {
        inherit pkgs;
        inherit (cfg) wayland;
      };
    in
    {
      programs.rofi = with pkgs; {
        enable = true;
        package = (if cfg.wayland then rofi-wayland else rofi);
        plugins = [
          rofi-emoji-better
          rofi-calc
        ];
      };

      wayland.windowManager.hyprland.settings.bind =
        mkIf config.modules.desktop.desktops.hyprland.enable
          [
            "$mod, Space, exec, rofi -show drun -display-drun \"Run\""
            "$mod, comma, exec, rofi -show emoji -modi emoji -kb-secondary-copy \"\" -kb-custom-1 \"Ctrl+c\" -display-emoji \"Emoji\""
            "$mod, C,     exec, rofi -show calc -modi calc -no-show-match -no-sort -display-calc \">\""
          ];

      xdg.desktopEntries = {
        sleep = {
          name = "Sleep / Suspend";
          exec = "systemctl suspend";
          terminal = false;
        };
        restart = {
          name = "Restart / Reboot";
          exec = "reboot";
          terminal = false;
        };
        poweroff = {
          name = "Shutdown / Power Off";
          exec = "poweroff";
          terminal = false;
        };
      };
    };
}
