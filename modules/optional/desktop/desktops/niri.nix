{
  getScript,
  mkModule,
  system,
  inputs,
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
    outputs = mkOption {
      type = anything;
      default = { };
    };
    batteryInfo = mkEnableOption "battery data in info notifications";
  };
  cfg = cfg: {
    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${system}.niri-unstable;
    };
  };
  hm =
    cfg:
    let
      notifyInfoScript = getExe (
        import ../../scripts/notify-info.nix {
          inherit lib pkgs;
          inherit (cfg) batteryInfo;
        }
      );
    in
    {
      imports = [ inputs.niri.homeModules.niri ];

      home.packages = with pkgs; [
        # Use latest git version
        # (xwayland-satellite.overrideAttrs (prev: {
        #   src = pkgs.fetchFromGitHub {
        #     owner = "Supreeeme";
        #     repo = "xwayland-satellite";
        #     rev = "b2613aec05f9e3f8488ef924203d62cafb712642";
        #     sha256 = "sha256-YhJex62HHVF6EfdGLIC01uM6jH8XJu5ryZ+LlhG7wMs=";
        #   };
        #   version = "git-b2613ae";

        #   cargoHash = "sha256-hA90Qh9bcvhIeXu4kXOH0D8rUcDMH5BXHLxx8Bf/CLI=";
        # }))
        xwayland-satellite
        xdg-desktop-portal-gnome
        playerctl
      ];

      programs.niri = {
        enable = true;
        package = inputs.niri.packages.${system}.niri-unstable;
        settings = {
          inherit (cfg) outputs;

          # Startup Apps
          spawn-at-startup =
            (lists: map (cmd: if builtins.isList cmd then { command = cmd; } else { command = [ cmd ]; }) lists)
              (
                [
                  [
                    "${pkgs.swaybg}/bin/swaybg"
                    "-i"
                    "/home/real/Pictures/wallpapers/purple_abstract.png"
                  ]
                  "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
                  "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
                  "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon"
                ]
                ++ (
                  if (config.modules.desktop.browser.zen.enable && config.modules.desktop.browser.zen.autoStart) then
                    [ "zen" ]
                  else
                    [ ]
                )
                ++ (
                  if (config.modules.desktop.discord.enable && config.modules.desktop.discord.autoStart) then
                    [ "discord" ]
                  else
                    [ ]
                )
              );

          # Window Rules
          window-rules = [
            # Make floating windows have rounded corners and shadows
            {
              matches = [ { is-floating = true; } ];
              geometry-corner-radius = {
                top-left = 15.0;
                top-right = 15.0;
                bottom-right = 15.0;
                bottom-left = 15.0;
              };
              clip-to-geometry = true;
              shadow = {
                enable = true;
                spread = 5;
                color = "#00000045";
              };
            }
            # Floating windows
            {
              matches = [
                { title = "MainPicker"; }
                { title = ".*Properties.*"; }
                { app-id = "Rofi"; }
              ];
              open-floating = true;
            }
            {
              matches = [ { app-id = "discord"; } ];
              open-on-workspace = "chat";
            }
            {
              matches = [
                { app-id = "zen(-twilight)?"; }
                { app-id = "firefox.*"; }
              ];
              open-on-workspace = "browser";
            }
          ];

          # Named Workspaces
          workspaces =
            (
              list:
              builtins.listToAttrs (
                map (e: {
                  name = e;
                  value.name = e;
                }) list
              )
            )
              [
                "browser"
                "chat"
                "code"
                "scratchpad"
              ];

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

            workspace-auto-back-and-forth = true;

            focus-follows-mouse.enable = true;
          };

          gestures.hot-corners.enable = false;

          layout =
            let
              gaps = 5;
            in
            {
              inherit gaps;
              struts = {
                left = -gaps;
                right = -gaps;
                top = -gaps;
                bottom = -gaps;
              };

              default-column-width.proportion = 1.0;

              focus-ring.enable = false;
            };

          binds =
            {
              # App keybinds
              "Mod+L".action.spawn = "youtube-music";
              "Mod+A".action.spawn = rofiSearchScript;
              "Alt+Semicolon".action.spawn = [
                rofiProjectsPickerScript
                "pick"
              ];
              "Mod+Escape".action.spawn = notifyInfoScript;
              ${if config.modules.desktop.terminal.kitty.enable then "Mod+Return" else null}.action.spawn =
                "kitty";
              ${if config.modules.desktop.appLauncher.rofi.enable then "Mod+Space" else null}.action.spawn = [
                "rofi"
                "-show"
                "drun"
                "-display-drun"
                "Run"
              ];
              ${if config.modules.desktop.appLauncher.rofi.enable then "Mod+Comma" else null}.action.spawn = [
                "rofi"
                "-show"
                "emoji"
                "-modi"
                "emoji"
                "-kb-secondary-copy"
                ""
                "-kb-custom-1"
                "Ctrl+c"
                "-display-emoji"
                "Emoji"
              ];
              ${if config.modules.desktop.appLauncher.rofi.enable then "Mod+C" else null}.action.spawn = [
                "rofi"
                "-show"
                "calc"
                "-modi"
                "calc"
                "-no-show-match"
                "-no-sort"
                "-display-calc"
                ">"
              ];
              ${if config.modules.services.openrazer.enable then "Mod+B" else null}.action.spawn =
                razerBatteryInfoScript;

              # Audio
              "Alt+0" = {
                allow-when-locked = true;
                action.spawn = [
                  volumeScript
                  "mute"
                ];
              };
              "Alt+Minus" = {
                allow-when-locked = true;
                action.spawn = [
                  volumeScript
                  "decrease"
                  (toString cfg.volumeStep)
                ];
              };
              "Alt+Equal" = {
                allow-when-locked = true;
                action.spawn = [
                  volumeScript
                  "increase"
                  (toString cfg.volumeStep)
                ];
              };
              "XF86AudioMute" = {
                allow-when-locked = true;
                action.spawn = [
                  volumeScript
                  "mute"
                ];
              };
              "XF86AudioLowerVolume" = {
                allow-when-locked = true;
                action.spawn = [
                  volumeScript
                  "decrease"
                  (toString cfg.volumeStep)
                ];
              };
              "XF86AudioRaiseVolume" = {
                allow-when-locked = true;
                action.spawn = [
                  volumeScript
                  "increase"
                  (toString cfg.volumeStep)
                ];
              };

              # Media Control
              "Alt+7".action.spawn = [
                "playerctl"
                "previous"
              ];
              "Alt+8".action.spawn = [
                "playerctl"
                "play-pause"
              ];
              "Alt+9".action.spawn = [
                "playerctl"
                "next"
              ];
              "XF86AudioPrev".action.spawn = [
                "playerctl"
                "previous"
              ];
              "XF86AudioPlay".action.spawn = [
                "playerctl"
                "play-pause"
              ];
              "XF86AudioNext".action.spawn = [
                "playerctl"
                "next"
              ];

              # Window Management
              "Mod+Q".action.close-window = { };
              "Mod+F".action.fullscreen-window = { };
              "Mod+V".action.toggle-window-floating = { };

              # Scrolling
              "Mod+WheelScrollUp".action.focus-column-left = { };
              "Mod+WheelScrollDown".action.focus-column-right = { };
            }
            # Workspaces
            //
              (
                list:
                let
                  workspaces_ =
                    list: prefix: action:
                    builtins.listToAttrs (
                      map (i: {
                        name = "${prefix}+${toString i}";
                        value.action.${action} = i;
                      }) list
                    );
                in
                (workspaces_ list "Mod" "focus-workspace")
                // (workspaces_ list "Mod+Shift" "move-column-to-workspace")
              )
                (builtins.genList (n: n + 1) 9)
            // {
              "Mod+S".action.focus-workspace = "scratchpad";
              "Mod+Shift+S".action.move-column-to-workspace = "scratchpad";
              "Mod+Grave".action.focus-workspace = 100;
              "Mod+Shift+Grave".action.move-column-to-workspace = 100;

              # Window Focusing
              "Mod+Left".action.focus-column-left = { };
              "Mod+Right".action.focus-column-right = { };
              "Mod+Shift+Left".action.move-column-left = { };
              "Mod+Shift+Right".action.move-column-right = { };

              # Screenshots
              "Alt+R".action.screenshot = { };
              "Print".action.screenshot-screen = { };
              "Alt+Print".action.screenshot-window = { };

              "Mod+Shift+P".action.power-off-monitors = { };
              "Ctrl+Alt+Delete".action.quit = { };
              "Mod+Slash".action.show-hotkey-overlay = { };
            };

          animations.shaders.window-resize = ''
            vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
              vec3 coords_next_geo = niri_curr_geo_to_next_geo * coords_curr_geo;

              vec3 coords_stretch = niri_geo_to_tex_next * coords_curr_geo;
              vec3 coords_crop = niri_geo_to_tex_next * coords_next_geo;

              // We can crop if the current window size is smaller than the next window
              // size. One way to tell is by comparing to 1.0 the X and Y scaling
              // coefficients in the current-to-next transformation matrix.
              bool can_crop_by_x = niri_curr_geo_to_next_geo[0][0] <= 1.0;
              bool can_crop_by_y = niri_curr_geo_to_next_geo[1][1] <= 1.0;

              vec3 coords = coords_stretch;
              if (can_crop_by_x)
                  coords.x = coords_crop.x;
              if (can_crop_by_y)
                  coords.y = coords_crop.y;

              vec4 color = texture2D(niri_tex_next, coords.st);

              // However, when we crop, we also want to crop out anything outside the
              // current geometry. This is because the area of the shader is unspecified
              // and usually bigger than the current geometry, so if we don't fill pixels
              // outside with transparency, the texture will leak out.
              //
              // When stretching, this is not an issue because the area outside will
              // correspond to client-side decoration shadows, which are already supposed
              // to be outside.
              if (can_crop_by_x && (coords_curr_geo.x < 0.0 || 1.0 < coords_curr_geo.x))
                  color = vec4(0.0);
              if (can_crop_by_y && (coords_curr_geo.y < 0.0 || 1.0 < coords_curr_geo.y))
                  color = vec4(0.0);

              return color;
            }
          '';

          # Misc
          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;
          screenshot-path = null; # dont save screenshots
        };
      };
    };
}
