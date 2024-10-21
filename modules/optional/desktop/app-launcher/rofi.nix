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
    home.packages = with pkgs; [ (if cfg.wayland then rofi-wayland else rofi) ];
    programs.rofi.enable = true;
    wayland.windowManager.hyprland.settings.bind = mkIf config.modules.desktop.desktops.hyprland.enable [
      "$mod, Space, exec, rofi -show drun"
    ];
  };
}
