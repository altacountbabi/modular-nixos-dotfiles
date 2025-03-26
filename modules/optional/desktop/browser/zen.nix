{
  mkModule,
  config,
  system,
  inputs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
mkModule {
  name = "desktop.browser.zen";
  path = "desktop.browser.zen";
  opts = with types; {
    autoStart = mkEnableOption "Zen as a startup app";
    package = mkOption {
      type = package;
      default = inputs.zen-browser.packages."${system}".twilight;
    };
  };
  hm =
    cfg:
    let
      desktops = config.modules.desktop.desktops;
    in
    {
      home.packages = [ cfg.package ];

      # Auto start
      wayland.windowManager.hyprland.settings.exec-once =
        mkIf (desktops.hyprland.enable && cfg.autoStart)
          [
            "[workspace 1 silent] zen --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland"
          ];
    };
}
