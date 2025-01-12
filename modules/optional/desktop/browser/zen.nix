{
  mkModule,
  config,
  system,
  inputs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
mkModule {
  name = "desktop.browser.zen";
  path = "desktop.browser.zen";
  opts.autoStart = mkEnableOption "Zen as a startup app";
  hm = cfg: {
    home.packages = [ inputs.zen-browser.packages."${system}".twilight ];
    wayland.windowManager.hyprland.settings.exec-once =
      mkIf (config.modules.desktop.desktops.hyprland.enable && cfg.autoStart)
        [
          "[workspace 1 silent] zen --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland"
        ];
  };
}
