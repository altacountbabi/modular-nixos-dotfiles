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
  hm = cfg: {
    programs.rofi = with pkgs; {
      enable = true;
      package = (if cfg.wayland then rofi-wayland else rofi);
      plugins = [ (if cfg.wayland then rofi-emoji-wayland else rofi-emoji) ];
    };

    wayland.windowManager.hyprland.settings.bind =
      mkIf config.modules.desktop.desktops.hyprland.enable
        [
          "$mod, Space, exec, rofi -show drun"
          # Emoji picker is broken right now (probably)
          "$mod, comma, exec, rofi -show emoji"
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
