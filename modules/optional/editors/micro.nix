{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

mkModule {
  name = "editor.micro";
  path = "editor.micro";
  hm = cfg: {
    home.packages = [ pkgs.micro ];
    programs.micro = {
      enable = true;
      catppuccin.enable = config.modules.colorscheme.catppuccin.enable;
    };
  };
}
