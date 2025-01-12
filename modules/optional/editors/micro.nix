{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

mkModule {
  name = "micro text editor";
  path = "editor.micro";
  hm = cfg: {
    home.packages = [ pkgs.micro ];
    programs.micro.enable = true;
  };
}
