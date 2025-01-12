{
  mkModule,
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (builtins) listToAttrs;
  inherit (lib) mkOption types;
in
mkModule {
  name = "catppuccin";
  path = "colorscheme.catppuccin";
  opts = with types; {
    accent = mkOption {
      type = enum [
        "blue"
        "flamingo"
        "green"
        "lavender"
        "maroon"
        "mauve"
        "peach"
        "pink"
        "red"
        "rosewater"
        "sapphire"
        "sky"
        "teal"
        "yellow"
      ];
      default = "lavender";
    };
    flavor = mkOption {
      type = enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "mocha";
    };
  };
  hm = cfg: {
    imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

    catppuccin = {
      enable = true;
      inherit (cfg) accent flavor;

      cursors = {
        enable = true;
        accent = "dark";
      };

      kvantum.enable = true;

      # TODO: Probably should make a function to make this more pretty.

      # Graphical Apps
      hyprland.enable = config.modules.desktop.desktops.hyprland.enable;
      rofi.enable = config.modules.desktop.appLauncher.rofi.enable;
      micro.enable = config.modules.editor.micro.enable;
      mako.enable = config.modules.desktop.notification.mako.enable;
      kitty.enable = config.modules.desktop.terminal.kitty.enable;

      # CLI Apps
      lazygit.enable = true;
      btop.enable = true;
      cava.enable = true;
      fish.enable = true;
      bat.enable = true;
    };

    qt = {
      style.name = "kvantum";
      platformTheme.name = "kvantum";
      enable = true;
    };
  };
}
