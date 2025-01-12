{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
mkModule {
  name = "desktop.browser.firefox";
  path = "desktop.browser.firefox";
  opts.autoStart = mkEnableOption "Firefox as a startup app";
  hm = cfg: {
    home.packages = [ pkgs.firefox ];
    wayland.windowManager.hyprland.settings.exec-once =
      mkIf (config.modules.desktop.desktops.hyprland.enable && cfg.autoStart)
        [
          "[workspace 1 silent] firefox"
        ];
  };
}
