{
  mkModule,
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
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

      # UI Toolkits
      kvantum.enable = true;
      gtk.enable = true;

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

    programs = {
      cava.enable = true;
      btop.enable = true;
    };

    qt = {
      style.name = "kvantum";
      platformTheme.name = "kvantum";
      enable = true;
    };

    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
