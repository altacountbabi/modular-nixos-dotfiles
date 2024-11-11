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
      catppuccin.enable = config.modules.colorscheme.catppuccin.enable;
    };
    wayland.windowManager.hyprland.settings.bind =
      mkIf config.modules.desktop.desktops.hyprland.enable
        [
          "$mod, Space, exec, rofi -show drun"
          "ALT, comma, exec, rofi -show emoji"
        ];
  };
}
