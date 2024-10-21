{
  mkModule,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    getExe
    types
    ;

  getScript = name: getExe (import ../../scripts/${name}.nix { inherit lib pkgs; });

  notifyInfoScript = getScript "notify-info";
  volumeScript = getScript "volume";
  wallpaperScript = getExe (
    pkgs.writeShellApplication {
      name = "wallpaper";
      runtimeInputs = with pkgs; [ swww ];
      text =
        let
          # Relative to home directory
          wallpaperPath = "Pictures/wallpapers";
        in
        ''
          if ! pidof swww-daemon > /dev/null; then
            hyprctl -i 0 dispatch exec swww-daemon
          fi

          random_wallpaper=$(find "$HOME/${wallpaperPath}" | shuf -n 1)
          swww img "$random_wallpaper"
        '';
    }
  );
in
mkModule {
  name = "hyprland";
  path = "desktop.desktops.hyprland";
  opts = with types; {
    volumeStep = mkOption {
      type = int;
      default = 5;
    };
    touchpadName = mkOption {
      type = str;
      description = "The name of the touchpad device, find with `hyprctl devices`";
      default = "elan0711:00-04f3:30eb-touchpad";
    };
    hyprcursor = mkEnableOption "hyprcursor";
  };
  cfg = cfg: { programs.hyprland.enable = true; };
}
