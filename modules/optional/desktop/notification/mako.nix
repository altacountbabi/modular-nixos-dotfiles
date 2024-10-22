{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
in
mkModule {
  name = "mako";
  path = "desktop.notification.mako";
  opts = with types; {
    cornerRadius = mkOption {
      type = int;
      default = 10;
    };
    anchor = mkOption {
      type = enum [
        "top-right"
        "top-center"
        "top-left"
        "bottom-right"
        "bottom-center"
        "bottom-left"
        "center"
      ];
      default = "top-center";
    };
  };
  hm = cfg: {
    home.packages = with pkgs; [ mako ];
    services.mako = mkIf (cfg.enable && config.modules.home-manager.enable) {
      enable = true;
      catppuccin.enable = config.modules.colorscheme.catppuccin.enable;
      borderRadius = cfg.cornerRadius;
      inherit (cfg) anchor;
    };
    wayland.windowManager.hyprland.settings.exec-once =
      mkIf config.modules.desktop.desktops.hyprland.enable
        [ "mako" ];
  };
}
