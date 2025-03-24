{
  getScript,
  mkModule,
  system,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;

  volumeScript = getScript "volume";
  colorPickerScript = getScript "color-picker";
  rofiSearchScript = getScript "rofi-search";
  razerBatteryInfoScript = getScript "razer-battery-info";
  rofiProjectsPickerScript = getScript "rofi-projects-picker";
in
mkModule {
  name = "niri wayland compositor";
  path = "desktop.desktops.niri";
  opts = with types; {
    volumeStep = mkOption {
      type = int;
      default = 5;
    };
  };
  cfg = cfg: { programs.niri.enable = true; };
  hm = cfg: {
    imports = [ inputs.niri.homeModules.niri ];

    home.packages = with pkgs; [
      xwayland-satellite
      xdg-desktop-portal-gnome
    ];

    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${system}.niri-unstable;
      settings = {
        outputs."DP-1".mode = {
          height = 1080;
          width = 1920;
          refresh = 240.0;
        };

        # Startup Apps
        spawn-at-startup =
          (lists: map (cmd: if builtins.isList cmd then { command = cmd; } else { command = [ cmd ]; }) lists)
            [
              "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
              "swww-daemon"
              "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
              "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon"

              "zen"
              "discord"
            ];

        # Window Rules
        window-rules = [
          # Make floating windows have rounded corners
          {
            matches = [ { is-floating = true; } ];
            geometry-corner-radius = {
              top-left = 15.0;
              top-right = 15.0;
              bottom-right = 15.0;
              bottom-left = 15.0;
            };
            clip-to-geometry = true;
          }
          # Floating windows
          {
            matches = [
              { title = "MainPicker"; }
              { title = ".*Properties.*"; }
            ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "discord"; } ];
            open-on-workspace = "chat";
          }
          {
            matches = [ { app-id = "zen(-twilight)?"; } ];
            open-on-workspace = "chat";
          }
        ];

        # Named Workspaces
        workspaces = {
          "browser" = { };
          "chat" = { };
          "music" = { };
        };

        # Environment Variables
        environment = {
          QT_QPA_PLATFORM = "wayland";
          DISPLAY = ":0";
        };

        input = {
          mouse = {
            accel-speed = 0.0;
            accel-profile = "flat";
          };
          focus-follows-mouse.enable = true;
        };

        layout = {
          gaps = 5;
          struts = {
            left = -5;
            right = -5;
            top = -5;
            bottom = -5;
          };

          default-column-width.proportion = 1.0;

          focus-ring.enable = false;
        };

        binds = {
          # App keybinds
          "Mod+Space".action.spawn = [
            "rofi"
            "-show"
            "drun"
            "-display-drun"
            "Run"
          ];
          "Mod+Return".action.spawn = "kitty";
          "Mod+L".action.spawn = "youtube-music";

          "Mod+Q".action.close-window = { };
          "Mod+F".action.fullscreen-window = { };
          "Mod+V".action.toggle-window-floating = { };

          # Audio
          "Alt+0" = {
            allow-when-locked = true;
            action.spawn = [
              volumeScript
              "t"
            ];
          };
          "Alt+Minus" = {
            allow-when-locked = true;
            action.spawn = [
              volumeScript
              "d"
              (toString cfg.volumeStep)
            ];
          };
          "Alt+Equal" = {
            allow-when-locked = true;
            action.spawn = [
              volumeScript
              "i"
              (toString cfg.volumeStep)
            ];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn = [
              volumeScript
              "t"
            ];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action.spawn = [
              volumeScript
              "d"
              (toString cfg.volumeStep)
            ];
          };
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn = [
              volumeScript
              "i"
              (toString cfg.volumeStep)
            ];
          };

          # Scrolling
          "Mod+WheelScrollUp" = {
            action.focus-column-left = { };
          };
          "Mod+WheelScrollDown" = {
            action.focus-column-right = { };
          };

          # Workspaces
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;
          "Mod+Grave".action.focus-workspace = 100;
          "Mod+Shift+Grave".action.move-column-to-workspace = 100;

          # Window Focusing
          "Mod+Left".action.focus-column-left = { };
          "Mod+Right".action.focus-column-right = { };
          "Mod+Shift+Left".action.move-column-left = { };
          "Mod+Shift+Right".action.move-column-right = { };

          # Screenshots
          "Print".action.screenshot = { };
          "Ctrl+Print".action.screenshot-screen = { };
          "Alt+Print".action.screenshot-window = { };

          "Mod+Shift+P".action.power-off-monitors = { };
          "Ctrl+Alt+Delete".action.quit = { };
          "Mod+Slash".action.show-hotkey-overlay = { };
        };

        # Misc
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;
      };
    };
  };
}
