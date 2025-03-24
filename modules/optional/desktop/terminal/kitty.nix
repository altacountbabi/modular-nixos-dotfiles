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
    mkIf
    types
    mkMerge
    ;
in
mkModule {
  name = "kitty terminal";
  path = "desktop.terminal.kitty";
  opts = with types; {
    font = {
      family = mkOption {
        type = str;
        default = "FiraCode Nerd Font Medium";
      };
      package = mkOption {
        type = package;
        default = pkgs.nerd-fonts.fira-code;
      };
      size = mkOption {
        type = int;
        default = 13;
      };
    };
    ligatures = mkOption {
      type = enum [
        true
        "cursor"
        false
      ];
      default = true;
    };
    line_height = mkOption {
      type = int;
      default = 5;
    };
    cursor = {
      beam = {
        enable = mkOption {
          type = bool;
          description = "Enable beam cursor shape";
          default = true;
        };
        thickness = mkOption {
          type = float;
          default = 1.5;
          description = "The thickness of the beam cursor (in pts).";
        };
      };
      underline = {
        enable = mkEnableOption "underline cursor shape";
        thickness = mkOption {
          type = float;
          default = 2.0;
          description = "The thickness of the underline cursor (in pts).";
        };
      };
      block.enable = mkEnableOption "block cursor shape";
    };
    opacity = mkOption {
      type = float;
      default = 1.0;
    };
    padding = mkOption {
      type = int;
      default = 5;
    };
  };
  hm =
    cfg:
    let
      desktops = config.modules.desktop.desktops;
    in
    {
      home.packages = with pkgs; [
        cfg.font.package
        kitty
      ];

      wayland.windowManager.hyprland.settings = mkIf desktops.hyprland.enable {
        bind = [ "$mod, Return, exec, kitty" ];
        # TODO: Allow for other terminals to add to the swallow regex
        misc.swallow_regex = "^(kitty)$";
      };

      programs.niri.settings.binds = mkIf desktops.niri.enable (mkMerge [
        { }
        { "Mod+Return".action.spawn = "kitty"; }
      ]);

      dconf = {
        enable = true;
        settings =
          let
            exec = "kitty";
            exec-arg = "";
          in
          {
            "org/gnome/desktop/default-applications/terminal" = {
              inherit exec exec-arg;
            };
            "org/cinnamon/desktop/default-applications/terminal" = {
              inherit exec exec-arg;
            };
          };
      };

      programs.kitty = {
        enable = true;
        settings = {
          # Font
          font_family = cfg.font.family;
          font_size = cfg.font.size;
          disable_ligatures = (
            if cfg.ligatures then
              "never"
            else if !cfg.ligatures then
              "always"
            else
              cfg.ligatures
          );
          adjust_line_height = cfg.line_height;
          box_drawing_scale = "0.1, 1, 1.5, 2";

          # Graphics
          sync_to_monitor = true;
          resize_debounce_time = 0;

          # Behaviour
          confirm_os_window_close = 0;

          # Visual / Layout
          window_padding_width = cfg.padding;
          window_margin_width = cfg.padding;
          background_opacity = toString cfg.opacity;
          placement_strategy = "center";

          # Cursor
          cursor_shape = (
            if cfg.cursor.beam.enable then
              "beam"
            else if cfg.cursor.underline.enable then
              "underline"
            else
              "block"
          );
          cursor_beam_thickness = cfg.cursor.beam.thickness;
          cursor_underline_thickness = cfg.cursor.underline.thickness;
          allow_remote_control = true;
        };
        keybindings = {
          "alt+shift+w" = "new_tab_with_cwd";
        };
      };
    };
}
