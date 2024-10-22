{
  mkModule,
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

      pointerCursor = {
        enable = true;
        accent = "dark";
      };
    };

    qt = {
      style = {
        catppuccin.enable = true;
        name = "kvantum";
      };
      platformTheme.name = "kvantum";
      enable = true;
    };

    programs = listToAttrs (
      map
        (prog: {
          name = prog;
          value = {
            catppuccin.enable = true;
          };
        })
        [
          "lazygit"
          "btop"
          "cava"
          "fish"
          "bat"
        ]
    );
  };
}
