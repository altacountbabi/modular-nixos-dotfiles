{
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

  getScript = name: getExe (import ../../scripts/${name}.nix { inherit lib pkgs; });

  notifyInfoScript = getScript "notify-info";
  volumeScript = getScript "volume";
  colorPickerScript = getScript "color-picker";
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
    hyprcursor = mkEnableOption "hyprcursor";
  };
  cfg = cfg: { programs.hyprland.enable = true; };
  hm =
    cfg:
    let
      inherit (builtins) concatLists genList toString;
    in
    {
      home.packages = with pkgs; [
        playerctl # media playback control
        grimblast # screenshot utility
        swww # wallpaper daemon
      ];

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
              "$mod, V, togglefloating"
              "$mod, F, fullscreen"
              "$mod SHIFT, F, fullscreenstate, 0 2"
              "$mod, P, pseudo"
              "$mod, J, togglesplit"
              "$mod, S, togglespecialworkspace, magic"
              "$mod SHIFT, S, movetoworkspace, special:magic"

              "$mod SHIFT, Left, swapwindow, l"
              "$mod SHIFT, Right, swapwindow, r"
              "$mod SHIFT, Up, swapwindow, u"
              "$mod SHIFT, Down, swapwindow, d"

              # Window Navigation
              "$mod, Left, movefocus, l"
              "$mod, Right, movefocus, r"
              "$mod, Up, movefocus, u"
              "$mod, Down, movefocus, d"

              # Misc
              "$mod, Tab, exec, ${notifyInfoScript}"
              "$mod, L, exec, youtube-music"
              "$mod, T, exec, cartridges"

              # Screenshotting
              "ALT, R, exec, grimblast --freeze copy area"
              "ALT SHIFT, R, exec, grimblast copy screen"

              # Color picker
              "$mod, n, exec, ${colorPickerScript}"

              # Media Control
              # (this makes a lot more sense on my keyboard instead of XF86 keys)
              "ALT, 7, exec, playerctl previous"
              "ALT, 8, exec, playerctl play-pause"
              "ALT, 9, exec, playerctl next"

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
          ];

          input = with config.modules.graphics; {
            # Keyboard
            kb_layout = xkb.layout;
            kb_variant = xkb.variant;
            kb_options = xkb.options;
            numlock_by_default = false;

            # Mouse
            sensitivity = -0.1;
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
            "rounding 0, floating:0, onworkspace:w[tv1]"
            "bordersize 0, floating:0, onworkspace:f[1]"
            "rounding 0, floating:0, onworkspace:f[1]"
          ];

          cursor.enable_hyprcursor = cfg.hyprcursor;

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            animate_manual_resizes = false;
            enable_swallow = true;
            swallow_exception_regex = "(qemu|wev)";
            initial_workspace_tracking = 0;
          };

          xwayland.force_zero_scaling = true;
        };
      };
    };
}
