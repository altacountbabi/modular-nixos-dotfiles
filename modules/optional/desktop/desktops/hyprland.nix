{
  getScript,
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    getExe
    types
    ;

  volumeScript = getScript "volume";
  colorPickerScript = getScript "color-picker";
  rofiSearchScript = getScript "rofi-search";
  razerBatteryInfoScript = getScript "razer-battery-info";
  rofiProjectsPickerScript = getScript "rofi-projects-picker";
  wallpaperScript =
    with pkgs;
    getExe (writeShellApplication {
      name = "wallpaper";
      runtimeInputs = [ swww ];
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
    });
in
mkModule {
  name = "hyprland";
  path = "desktop.desktops.hyprland";
  opts = with types; {
    volumeStep = mkOption {
      type = int;
      default = 5;
    };
    kbResizeStep = mkOption {
      type = int;
      default = 50;
    };
    touchpadName = mkOption {
      type = str;
      description = "The name of the touchpad device, find with `hyprctl devices`";
      default = "elan0711:00-04f3:30eb-touchpad";
    };
    monitor = mkOption {
      type = listOf str;
      description = "Monitor config";
      default = [ ];
    };
    batteryInfo = mkEnableOption "battery info in info notifications";
    hyprcursor = mkEnableOption "hyprcursor";
  };
  cfg = cfg: { programs.hyprland.enable = true; };
  hm =
    cfg:
    let
      inherit (builtins) concatLists genList toString;

      notifyInfoScript = getExe (
        import ../../scripts/notify-info.nix {
          inherit lib pkgs;
          inherit (cfg) batteryInfo;
        }
      );
    in
    {
      home.packages = with pkgs; [
        playerctl # media playback control
        grimblast # screenshot utility
        swww # wallpaper daemon
        wl-clipboard # clipboard
        hyprprop
      ];

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
        ];
      };

      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          inherit (cfg) monitor;

          "$mod" = "SUPER";
          bind =
            [
              "$mod SHIFT, M, exit"
              "$mod, Q, killactive"

              # Layout Management
              "$mod, V,       togglefloating"
              "$mod, F,       fullscreen"
              "$mod SHIFT, F, fullscreenstate, 0 2"
              "$mod, P,       pseudo"
              "$mod, J,       togglesplit"
              "$mod, S,       togglespecialworkspace, magic"
              "$mod SHIFT, S, movetoworkspace, special:magic"

              "$mod SHIFT, Left,  swapwindow, l"
              "$mod SHIFT, Right, swapwindow, r"
              "$mod SHIFT, Up,    swapwindow, u"
              "$mod SHIFT, Down,  swapwindow, d"

              # Window Navigation
              "$mod, Left,  movefocus, l"
              "$mod, Right, movefocus, r"
              "$mod, Up,    movefocus, u"
              "$mod, Down,  movefocus, d"

              # Groups
              "$mod,       G,   togglegroup"
              "$mod,       Tab, changegroupactive, f"
              "$mod SHIFT, Tab, changegroupactive, b"

              # Misc
              (
                if config.modules.services.openrazer.enable then
                  "$mod, B,     exec, ${razerBatteryInfoScript}"
                else
                  ""
              )
              "$mod, Escape,    exec, ${notifyInfoScript}"
              "$mod, A,         exec, ${rofiSearchScript}"
              "ALT,  semicolon, exec, ${rofiProjectsPickerScript} pick"
              "$mod, L,         exec, youtube-music"
              "$mod, T,         exec, cartridges"

              # Screenshotting
              "ALT, R,       exec, grimblast --freeze copy area"
              "ALT SHIFT, R, exec, grimblast copy screen"

              # Color picker
              "$mod, n, exec, ${colorPickerScript}"

              # Media Control
              "ALT, 7, exec, playerctl previous"
              "ALT, 8, exec, playerctl play-pause"
              "ALT, 9, exec, playerctl next"

              ", XF86AudioPrev, exec, playerctl previous"
              ", XF86AudioPlay, exec, playerctl play-pause"
              ", XF86AudioNext, exec, playerctl next"

              "$mod, grave, workspace, 999"
            ]
            # Workspace Switching
            ++ (concatLists (
              genList (
                x:
                let
                  ws =
                    let
                      c = (x + 1) / 10;
                    in
                    toString (x + 1 - (c * 10));
                in
                [
                  "$mod, ${ws}, workspace, ${toString (x + 1)}"
                  "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                ]
              ) 10
            ));
          binde = [
            # Volume Keys
            "ALT, 0, exec, ${volumeScript} t"
            "ALT, minus, exec, ${volumeScript} d ${toString cfg.volumeStep}"
            "ALT, equal, exec, ${volumeScript} i ${toString cfg.volumeStep}"

            ", XF86AudioMute, exec, ${volumeScript} t"
            ", XF86AudioLowerVolume, exec, ${volumeScript} d ${toString cfg.volumeStep}"
            ", XF86AudioRaiseVolume, exec, ${volumeScript} i ${toString cfg.volumeStep}"

            # Window Resizing
            "$mod CTRL, Right, resizeactive, ${toString cfg.kbResizeStep} 0"
            "$mod CTRL, Left, resizeactive, -${toString cfg.kbResizeStep} 0"
            "$mod CTRL, Up, resizeactive, 0 -${toString cfg.kbResizeStep}"
            "$mod CTRL, Down, resizeactive, 0 ${toString cfg.kbResizeStep}"
          ];
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

          # Startup Apps
          exec-once = [
            # cursor
            "hyprctl setcursor Adwaita 24"
            # privilege escalation gui popup
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            # wallpaper daemon
            "swww-daemon"
            # set random wallpaper
            "${wallpaperScript}"
            # start keyring daemon
            "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon"
          ];

          input = with config.modules.graphics; {
            # Keyboard
            kb_layout = xkb.layout;
            kb_variant = xkb.variant;
            kb_options = xkb.options;
            numlock_by_default = false;

            # Mouse
            sensitivity = 0;
            follow_mouse = 1;
            mouse_refocus = false;
            accel_profile = "flat";

            # Touchpad
            touchpad = {
              natural_scroll = true;
              drag_lock = true;
            };
          };

          device = {
            # Enable mouse acceleration for touchpad.
            name = cfg.touchpadName;
            accel_profile = "adaptive";
          };

          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 0;
            layout = "dwindle";
          };

          decoration = {
            rounding = 15;

            blur = {
              enabled = true;
              size = 10;
              passes = 3;
              noise = 0.1;
            };

            shadow = {
              enabled = true;
              range = 14;
              render_power = 3;
              ignore_window = true;
              color = "rgba(00000045)";
            };

            dim_special = 0.2;
          };

          animations = {
            enabled = true;

            bezier = "smallOvershoot, 0.05, 0.9, 0, 1.05";
            animation = [
              "windows, 1, 7, smallOvershoot, slide"
              "windowsOut, 1, 7, default, slide"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, smallOvershoot"
            ];
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          # No gaps when only 1 window
          workspace = [
            "w[tv1], gapsout:0, gapsin:0"
            "f[1], gapsout:0, gapsin:0"
          ];
          windowrulev2 = [
            "bordersize 0, floating:0, onworkspace:w[tv1]"
            "rounding 0,   floating:0, onworkspace:w[tv1]"
            "bordersize 0, floating:0, onworkspace:f[1]"
            "rounding 0,   floating:0, onworkspace:f[1]"

            # Make file/folder info windows in file managers floating
            "float, title:(.*Properties.*)"

            "opacity 0.65, initialTitle:as_toolbar"
            "norounding, initialTitle:as_toolbar"
            "noblur, initialTitle:as_toolbar"
            "pin, initialTitle:as_toolbar"
          ];

          cursor.enable_hyprcursor = true;
          env = [
            "XCURSOR_SIZE,24"
            "XCURSOR_THEME,Adwaita"
            "HYPRCURSOR_THEME,Adwaita"
            "HYPRCURSOR_SIZE,24"
          ];

          group.groupbar = {
            height = 0;
            font_size = 0;
            # https://github.com/catppuccin/catppuccin/raw/main/assets/palette/circles/mocha_mauve.png
            "col.active" = "0xffcba6f7";
            # Transparent
            "col.inactive" = "0x00000000";
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            animate_manual_resizes = false;
            enable_swallow = false;
            swallow_exception_regex = "(qemu|wev)";
            initial_workspace_tracking = 0;
            middle_click_paste = false;
          };

          xwayland.force_zero_scaling = true;
        };
      };
    };
}
