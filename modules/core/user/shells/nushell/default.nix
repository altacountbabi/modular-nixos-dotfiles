{
  mkModule,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
mkModule {
  name = "nushell";
  path = "shells.nushell";
  opts = with types; {
    enable = mkOption {
      type = bool;
      default = config.modules.user.shell == pkgs.nushell;
    };
  };
  hm = cfg: {
    programs.nushell = {
      enable = true;
      configFile.text =
        (builtins.readFile ./config.nu)
        + (with pkgs; ''
          $env.XDG_DATA_DIRS = $"${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:($env.XDG_DATA_DIRS)";
          $env.GIO_MODULE_DIR = "${glib-networking}/lib/gio/modules/";
        '');
      envFile.source = ./env.nu;
    };
  };
}
